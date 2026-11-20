#!/usr/bin/env python3
"""Mantiene un índice acumulativo de emotes y paquetes de animación de Roblox."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from typing import Any
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parent
CATALOG_URL = "https://catalog.roblox.com/v1/search/items/details"
TASK_NAME = "RobloxCatalogSync"
EMOTE_ASSET_TYPE_ID = 61
ANIMATION_BUNDLE_TYPE_ID = 2
EMOTE_SEED_URL = (
    "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json"
)
ANIMATION_SEED_URL = (
    "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/AnimationSniper.json"
)
MINIMUM_EMOTE_BASELINE = 10_000
MINIMUM_ANIMATION_BASELINE = 5_000
ANIMATION_SLOT_BY_ASSET_TYPE = {
    48: "1",
    50: "2",
    55: "3",
    54: "4",
    51: "5",
    53: "6",
    52: "7",
}
PAGE_SIZE = 30


class ApiError(RuntimeError):
    pass


class RobloxApi:
    def __init__(self, min_interval: float = 2.0, retries: int = 6) -> None:
        self.min_interval = min_interval
        self.retries = retries
        self.last_request = 0.0

    def get_json(self, url: str) -> Any:
        for attempt in range(self.retries + 1):
            elapsed = time.monotonic() - self.last_request
            if elapsed < self.min_interval:
                time.sleep(self.min_interval - elapsed)

            request = Request(
                url,
                headers={
                    "Accept": "application/json",
                    "User-Agent": "RobloxCatalogSync/1.0 (public catalog index)",
                },
            )
            try:
                with urlopen(request, timeout=30) as response:
                    self.last_request = time.monotonic()
                    return json.loads(response.read().decode("utf-8"))
            except HTTPError as exc:
                self.last_request = time.monotonic()
                if exc.code not in (429, 500, 502, 503, 504) or attempt >= self.retries:
                    detail = exc.read(500).decode("utf-8", errors="replace")
                    raise ApiError(f"Roblox API respondió HTTP {exc.code} para {url}: {detail}") from exc
                delay = self._retry_after(exc.headers.get("Retry-After"))
                time.sleep(max(delay, min(2**attempt, 60)))
            except (OSError, json.JSONDecodeError) as exc:
                self.last_request = time.monotonic()
                if attempt >= self.retries:
                    raise ApiError(f"No se pudo consultar Roblox en {url}: {exc}") from exc
                time.sleep(min(2**attempt, 60))

        raise ApiError(f"Se agotaron los reintentos para {url}")

    @staticmethod
    def _retry_after(value: str | None) -> float:
        if not value:
            return 0.0
        try:
            return max(0.0, float(value))
        except ValueError:
            try:
                retry_time = parsedate_to_datetime(value)
                return max(0.0, (retry_time - datetime.now(timezone.utc)).total_seconds())
            except (TypeError, ValueError, OverflowError):
                return 0.0


def catalog_items(
    api: RobloxApi,
    params: dict[str, Any],
    *,
    expected_asset_type: int | None = None,
    expected_bundle_type: int | None = None,
) -> list[dict[str, Any]]:
    items_by_id: dict[int, dict[str, Any]] = {}
    cursor: str | None = None
    seen_cursors: set[str] = set()
    page_number = 0

    while True:
        page_params = {**params, "Limit": PAGE_SIZE}
        if cursor:
            page_params["Cursor"] = cursor
        url = f"{CATALOG_URL}?{urlencode(page_params)}"
        result = api.get_json(url)

        if not isinstance(result, dict) or not isinstance(result.get("data"), list):
            raise ApiError(f"Respuesta inesperada del catálogo: {url}")
        page_number += 1

        for item in result["data"]:
            if not isinstance(item, dict):
                continue
            if expected_asset_type is not None and item.get("assetType") != expected_asset_type:
                raise ApiError(
                    "El catálogo devolvió un assetType distinto al filtro solicitado."
                )
            if expected_bundle_type is not None and (
                item.get("itemType") != "Bundle"
                or item.get("bundleType") != expected_bundle_type
            ):
                raise ApiError(
                    "El catálogo devolvió un resultado que no es el paquete de animación solicitado."
                )
            asset_id = item.get("id")
            name = item.get("name")
            if isinstance(asset_id, int) and isinstance(name, str):
                entry: dict[str, Any] = {"id": asset_id, "name": name}
                if expected_bundle_type is not None:
                    bundled_items: dict[str, list[int]] = {}
                    components = item.get("bundledItems")
                    if not isinstance(components, list):
                        raise ApiError(
                            f"El paquete de animación {asset_id} no contiene sus componentes."
                        )
                    for component in components:
                        if not isinstance(component, dict):
                            continue
                        slot = ANIMATION_SLOT_BY_ASSET_TYPE.get(component.get("assetType"))
                        component_id = component.get("id")
                        if slot and isinstance(component_id, int):
                            bundled_items.setdefault(slot, []).append(component_id)
                    entry["bundledItems"] = {
                        slot: bundled_items[slot]
                        for slot in sorted(bundled_items, key=int)
                    }
                items_by_id[asset_id] = entry

        next_cursor = result.get("nextPageCursor")
        if not next_cursor:
            break
        if not isinstance(next_cursor, str) or next_cursor in seen_cursors:
            raise ApiError("Roblox devolvió un cursor de paginación repetido o inválido.")
        seen_cursors.add(next_cursor)
        cursor = next_cursor
        if page_number % 10 == 0:
            print(f"  Páginas: {page_number}; elementos: {len(items_by_id)}")

    return sorted(items_by_id.values(), key=lambda item: (item["name"].casefold(), item["id"]))


def get_catalog_data(api: RobloxApi) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    emotes_by_id: dict[int, dict[str, Any]] = {}
    emote_searches = (
        {"Category": 12, "Subcategory": 39, "SortType": 3},
    )
    for index, params in enumerate(emote_searches, start=1):
        print(f"Buscando emotes del catálogo ({index}/{len(emote_searches)})...")
        for item in catalog_items(api, params, expected_asset_type=EMOTE_ASSET_TYPE_ID):
            emotes_by_id[item["id"]] = item

    animations_by_id: dict[int, dict[str, Any]] = {}
    animation_searches = (
        {
            "Category": 12,
            "Subcategory": 38,
            "salesTypeFilter": 1,
            "SortType": 3,
            "IncludeNotForSale": "true",
        },
    )
    for index, params in enumerate(animation_searches, start=1):
        print(f"Buscando paquetes de animación ({index}/{len(animation_searches)})...")
        for item in catalog_items(api, params, expected_bundle_type=ANIMATION_BUNDLE_TYPE_ID):
            animations_by_id[item["id"]] = item

    emotes = sorted(
        emotes_by_id.values(),
        key=lambda item: (item["name"].casefold(), item["id"]),
    )
    animations = sorted(
        animations_by_id.values(),
        key=lambda item: (item["name"].casefold(), item["id"]),
    )
    if not emotes:
        raise ApiError("Roblox devolvió cero emotes; no se actualizaron los JSON.")
    if not animations:
        raise ApiError("Roblox devolvió cero paquetes de animación; no se actualizaron los JSON.")
    return emotes, animations


def normalize_item(item: Any, *, bundle_records: bool) -> dict[str, Any] | None:
    if not isinstance(item, dict):
        return None
    asset_id = item.get("id")
    name = item.get("name")
    if not isinstance(asset_id, int) or not isinstance(name, str):
        return None
    if not bundle_records:
        if "bundledItems" in item:
            return None
        return {"id": asset_id, "name": name}

    bundled_items = item.get("bundledItems")
    if not isinstance(bundled_items, dict):
        return None
    normalized_bundles: dict[str, list[int]] = {}
    for slot, ids in bundled_items.items():
        if not isinstance(slot, str) or not isinstance(ids, list):
            continue
        valid_ids = [component_id for component_id in ids if isinstance(component_id, int)]
        if valid_ids:
            normalized_bundles[slot] = valid_ids
    if not normalized_bundles:
        return None
    return {
        "id": asset_id,
        "name": name,
        "bundledItems": normalized_bundles,
    }


def read_local_items(path: Path, *, bundle_records: bool) -> dict[int, dict[str, Any]]:
    if not path.exists():
        return {}
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ApiError(f"No se pudo leer el JSON previo {path.name}: {exc}") from exc
    if not isinstance(payload, dict) or not isinstance(payload.get("data"), list):
        raise ApiError(f"El JSON previo {path.name} no tiene el formato esperado.")

    items: dict[int, dict[str, Any]] = {}
    for value in payload["data"]:
        item = normalize_item(value, bundle_records=bundle_records)
        if item:
            items[item["id"]] = item
    return items


def load_seed(
    api: RobloxApi,
    url: str,
    *,
    bundle_records: bool,
    minimum_items: int,
) -> dict[int, dict[str, Any]]:
    payload = api.get_json(url)
    if not isinstance(payload, dict) or not isinstance(payload.get("data"), list):
        raise ApiError(f"La lista inicial descargada de {url} no tiene el formato esperado.")
    items: dict[int, dict[str, Any]] = {}
    for value in payload["data"]:
        item = normalize_item(value, bundle_records=bundle_records)
        if item:
            items[item["id"]] = item
    if len(items) < minimum_items:
        raise ApiError(
            f"La lista inicial de {url} está incompleta "
            f"({len(items)} elementos; se esperaban al menos {minimum_items})."
        )
    return items


def merge_items(
    existing: dict[int, dict[str, Any]],
    additions: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    merged = dict(existing)
    for item in additions:
        merged[item["id"]] = item
    return sorted(merged.values(), key=lambda item: (item["name"].casefold(), item["id"]))


def make_payload(items: list[dict[str, Any]], timestamp: str) -> dict[str, Any]:
    return {
        "keyword": None,
        "totalItems": len(items),
        "lastUpdate": timestamp,
        "data": items,
    }


def write_json(path: Path, payload: dict[str, Any]) -> None:
    temporary_path = path.with_suffix(path.suffix + ".tmp")
    try:
        temporary_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        os.replace(temporary_path, path)
    finally:
        if temporary_path.exists():
            temporary_path.unlink()


def install_scheduler(schedule_time: str) -> None:
    if os.name != "nt":
        raise ApiError("La instalación automática del Programador de tareas solo está disponible en Windows.")
    try:
        datetime.strptime(schedule_time, "%H:%M")
    except ValueError as exc:
        raise ApiError("La hora debe tener el formato HH:MM, por ejemplo 03:00.") from exc

    command = subprocess.list2cmdline(
        [sys.executable, str(Path(__file__).resolve()), "--once"]
    )
    result = subprocess.run(
        [
            "schtasks.exe",
            "/Create",
            "/SC",
            "DAILY",
            "/ST",
            schedule_time,
            "/TN",
            TASK_NAME,
            "/TR",
            command,
            "/F",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        detail = (result.stderr or result.stdout).strip()
        raise ApiError(f"No se pudo crear la tarea diaria de Windows: {detail}")
    print(f"Tarea diaria instalada ({schedule_time}, hora local): {TASK_NAME}")


def remove_scheduler() -> None:
    if os.name != "nt":
        raise ApiError("La eliminación del Programador de tareas solo está disponible en Windows.")
    result = subprocess.run(
        ["schtasks.exe", "/Delete", "/TN", TASK_NAME, "/F"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        detail = (result.stderr or result.stdout).strip()
        raise ApiError(f"No se pudo eliminar la tarea de Windows: {detail}")
    print(f"Tarea eliminada: {TASK_NAME}")


def sync_catalog(min_interval: float) -> None:
    api = RobloxApi(min_interval=min_interval)
    emotes_path = ROOT / "emotes.json"
    animations_path = ROOT / "animations.json"
    existing_emotes = read_local_items(emotes_path, bundle_records=False)
    existing_animations = read_local_items(animations_path, bundle_records=True)

    if len(existing_emotes) < MINIMUM_EMOTE_BASELINE:
        print("Cargando la lista completa inicial de emotes...")
        seed_emotes = load_seed(
            api,
            EMOTE_SEED_URL,
            bundle_records=False,
            minimum_items=MINIMUM_EMOTE_BASELINE,
        )
        existing_emotes = {**existing_emotes, **seed_emotes}
    if len(existing_animations) < MINIMUM_ANIMATION_BASELINE:
        print("Cargando la lista completa inicial de paquetes de animación...")
        seed_animations = load_seed(
            api,
            ANIMATION_SEED_URL,
            bundle_records=True,
            minimum_items=MINIMUM_ANIMATION_BASELINE,
        )
        existing_animations = {**existing_animations, **seed_animations}

    timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    write_json(emotes_path, make_payload(
        sorted(existing_emotes.values(), key=lambda item: (item["name"].casefold(), item["id"])),
        timestamp,
    ))
    write_json(animations_path, make_payload(
        sorted(existing_animations.values(), key=lambda item: (item["name"].casefold(), item["id"])),
        timestamp,
    ))
    print(
        f"Listas completas guardadas: {len(existing_emotes)} emotes, "
        f"{len(existing_animations)} paquetes de animación."
    )

    print(
        "Roblox limita cada búsqueda a 1.000 resultados; se conserva la lista "
        "completa y se agregan los resultados recientes."
    )
    discovered_emotes, discovered_animations = get_catalog_data(api)
    emotes = merge_items(existing_emotes, discovered_emotes)
    animations = merge_items(existing_animations, discovered_animations)
    timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")

    outputs = (
        (emotes_path, emotes),
        (animations_path, animations),
    )
    payloads = [
        (path, make_payload(items, timestamp))
        for path, items in outputs
    ]
    for path, payload in payloads:
        write_json(path, payload)
        print(f"{path.name}: {payload['totalItems']} elementos.")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Descarga y compara emotes y animaciones públicas del catálogo Roblox."
    )
    parser.add_argument(
        "--install-scheduler",
        action="store_true",
        help="Instala una tarea diaria de Windows y ejecuta una actualización ahora.",
    )
    parser.add_argument(
        "--remove-scheduler",
        action="store_true",
        help="Elimina la tarea diaria de Windows.",
    )
    parser.add_argument(
        "--schedule-time",
        default="03:00",
        help="Hora local para la tarea diaria (HH:MM; predeterminado: 03:00).",
    )
    parser.add_argument(
        "--min-interval",
        type=float,
        default=2.0,
        help="Pausa mínima entre solicitudes en segundos (predeterminado: 2).",
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="Ejecuta una actualización y termina (comportamiento predeterminado).",
    )
    args = parser.parse_args()

    try:
        if args.remove_scheduler:
            remove_scheduler()
            return 0
        if args.min_interval < 0:
            raise ApiError("--min-interval no puede ser negativo.")
        if args.install_scheduler:
            install_scheduler(args.schedule_time)
        sync_catalog(args.min_interval)
    except (ApiError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
