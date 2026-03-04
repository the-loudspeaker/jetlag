#!/usr/bin/env python3
"""Fetch or regenerate metro line/station GeoJSON assets."""
import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets" / "metro"
LINE_ASSET = ASSETS_DIR / "bengaluru_metro_lines.geojson"
STATION_ASSET = ASSETS_DIR / "bengaluru_metro_stations.geojson"

# More accurate defaults in case fetch fails
DEFAULT_LINES = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "properties": {"name": "Purple Line", "line": "Purple", "color": "#702082"},
            "geometry": {
                "type": "MultiLineString",
                "coordinates": [
                    [[77.464, 12.923], [77.754, 13.000]],
                ],
            },
        },
        {
            "type": "Feature",
            "properties": {"name": "Green Line", "line": "Green", "color": "#009739"},
            "geometry": {
                "type": "MultiLineString",
                "coordinates": [
                    [[77.546, 13.045], [77.625, 12.865]],
                ],
            },
        },
    ],
}

DEFAULT_STATIONS = {
    "type": "FeatureCollection",
    "features": [
        {"type": "Feature", "properties": {"name": "Majestic (Nadaprabhu Kempegowda)", "line": "Purple"}, "geometry": {"type": "Point", "coordinates": [77.5728, 12.9757]}},
        {"type": "Feature", "properties": {"name": "M.G. Road", "line": "Purple"}, "geometry": {"type": "Point", "coordinates": [77.6067, 12.9755]}},
        {"type": "Feature", "properties": {"name": "Indiranagar", "line": "Purple"}, "geometry": {"type": "Point", "coordinates": [77.6386, 12.9783]}},
        {"type": "Feature", "properties": {"name": "Cubbon Park", "line": "Purple"}, "geometry": {"type": "Point", "coordinates": [77.5975, 12.9809]}},
        {"type": "Feature", "properties": {"name": "Whitefield (Kadugodi)", "line": "Purple"}, "geometry": {"type": "Point", "coordinates": [77.7579, 12.9957]}},
        {"type": "Feature", "properties": {"name": "Yeshwantpur", "line": "Green"}, "geometry": {"type": "Point", "coordinates": [77.5498, 13.0232]}},
        {"type": "Feature", "properties": {"name": "Jayanagar", "line": "Green"}, "geometry": {"type": "Point", "coordinates": [77.5801, 12.9295]}},
        {"type": "Feature", "properties": {"name": "Silk Institute", "line": "Green"}, "geometry": {"type": "Point", "coordinates": [77.5299, 12.8617]}},
    ],
}

LINES_QUERY = """
[out:json][timeout:90];
relation[route=subway](12.8,77.4,13.2,77.8);
out geom;
"""

STATIONS_QUERY = """
[out:json][timeout:90];
node[railway=station](12.8,77.4,13.2,77.8);
out;
"""

PURPLE_STATIONS = {
    "Challaghatta", "Kengeri", "Kengeri Bus Terminal", "Pattanagere", "Rajarajeshwari Nagar",
    "Jnanabharathi", "Pantharapalya - Nayandahalli", "Mysore Road", "Deepanjali Nagar",
    "Attiguppe", "Vijayanagar", "Sri Balagangadharanatha Swamiji Station, Hosahalli",
    "Hosahalli", "Magadi Road", "Krantivira Sangolli Rayanna Railway Station",
    "Sir M. Visvesvaraya Stn., Central College", "Dr. B. R. Ambedkar Station, Vidhana Soudha",
    "Vidhana Soudha", "Cubbon Park", "Mahatma Gandhi Road", "M.G. Road", "Trinity",
    "Halasuru", "Indiranagar", "Swami Vivekananda Road", "Baiyappanahalli",
    "Benniganahalli", "Krishnarajapura", "Singayyanapalya", "Garudacharpalya",
    "Hoodi", "Seetharampalya", "Kundalahalli", "Nallurahalli", "Sri Sathya Sai Hospital",
    "Pattandur Agrahara", "Hopefarm Channasandra", "Whitefield (Kadugodi)", "Kadugodi Tree Park"
}

GREEN_STATIONS = {
    "Madavara", "Chikkabidarakallu", "Manjunathanagara", "Nagasandra", "Dasarahalli",
    "Jalahalli", "Peenya Industry", "Peenya", "Goraguntepalya", "Yeshwantpur",
    "Sandal Soap Factory", "Mahalakshmi", "Rajajinagar", "Mahakavi Kuvempu Road",
    "Srirampura", "Mantri Square Sampige Road", "Chickpete", "Krishna Rajendra Market",
    "K.R. Market", "National College", "Lalbagh", "South End Circle", "Jayanagar",
    "Rashtreeya Vidyalaya Road", "RV Road", "Banashankari", "Jaya Prakash Nagar",
    "JP Nagar", "Yelachenahalli", "Konanakunte Cross", "Doddakallasandra",
    "Vajarahalli", "Thalaghattapura", "Silk Institute"
}


def fetch_overpass(query: str) -> dict:
    print(f"Fetching from Overpass...")
    req = urllib.request.Request(
        OVERPASS_URL,
        data=query.encode('utf-8'),
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = json.load(resp)
        print(f"Overpass returned {len(data.get('elements', []))} elements.")
        return data


def chain_ways(multi_coords):
    if not multi_coords:
        return []
    # Start with the longest way
    ways = sorted(multi_coords, key=len, reverse=True)
    main_chain = ways[0]
    remaining = ways[1:]
    
    changed = True
    while changed:
        changed = False
        for i, way in enumerate(remaining):
            if way[0] == main_chain[-1]:
                main_chain.extend(way[1:])
                remaining.pop(i)
                changed = True
                break
            elif way[-1] == main_chain[0]:
                main_chain = way[:-1] + main_chain
                remaining.pop(i)
                changed = True
                break
            elif way[-1] == main_chain[-1]:
                main_chain.extend(list(reversed(way))[1:])
                remaining.pop(i)
                changed = True
                break
            elif way[0] == main_chain[0]:
                main_chain = list(reversed(way))[:-1] + main_chain
                remaining.pop(i)
                changed = True
                break
    return [main_chain]


COLOR_MAP = {
    "purple": "#702082",
    "green": "#009739",
    "yellow": "#FFD600", # Bright yellow
    "pink": "#E91E63",
}

def convert_lines(response: dict) -> dict | None:
    elements = response.get('elements') or []
    line_features = {} # line_ref -> feature
    
    for element in elements:
        if element.get('type') != 'relation':
            continue
        
        props = element.get('tags', {})
        line_name = props.get('name', 'Metro Line')
        line_ref = props.get('ref', props.get('line', 'Metro'))
        
        # Filter for main lines, avoid under construction if possible
        if props.get('state') == 'proposed' or 'construction' in line_name.lower():
            continue

        # Extract geometry from members
        multi_coords = []
        members = element.get('members', [])
        for member in members:
            if member.get('type') == 'way' and 'geometry' in member:
                way_coords = [[pt['lon'], pt['lat']] for pt in member['geometry']]
                if way_coords:
                    multi_coords.append(way_coords)
        
        if not multi_coords:
            continue
            
        # Chain ways to get a single continuous line
        single_chain = chain_ways(multi_coords)
        total_pts = len(single_chain[0])
        
        color = props.get('colour', props.get('color', '#444444')).lower()
        if line_ref.lower() in COLOR_MAP:
            color = COLOR_MAP[line_ref.lower()]
        elif color in COLOR_MAP:
            color = COLOR_MAP[color]
            
        feature = {
            'type': 'Feature',
            'properties': {
                'name': line_name,
                'line': line_ref,
                'color': color,
            },
            'geometry': {'type': 'MultiLineString', 'coordinates': single_chain},
        }
        
        # Keep the one with the most coordinates for each line_ref
        if line_ref not in line_features or total_pts > line_features[line_ref]['_total_pts']:
            feature['_total_pts'] = total_pts
            line_features[line_ref] = feature
            
    for f in line_features.values():
        f.pop('_total_pts', None)
        
    features = list(line_features.values())
    return {'type': 'FeatureCollection', 'features': features} if features else None


def convert_stations(response: dict) -> dict | None:
    elements = response.get('elements') or []
    features = []
    seen_names = set()
    for element in elements:
        if element.get('type') != 'node':
            continue
        lat = element.get('lat')
        lon = element.get('lon')
        if lat is None or lon is None:
            continue
        props = element.get('tags', {})
        name = props.get('name')
        if not name or name in seen_names:
            continue
        
        # Filter for actual metro stations
        if props.get('railway') != 'station':
            continue
        if props.get('station') != 'subway' and props.get('subway') != 'yes' and 'metro' not in props.get('operator', '').lower():
            continue

        seen_names.add(name)
        
        # Heuristic to assign line
        line_ref = props.get('ref', 'Metro')
        if 'line' in props:
            line_ref = props['line']
            
        if line_ref == 'Metro':
            if name in PURPLE_STATIONS:
                line_ref = "Purple"
            elif name in GREEN_STATIONS:
                line_ref = "Green"
            elif "Majestic" in name:
                line_ref = "Purple"
        
        features.append(
            {
                'type': 'Feature',
                'properties': {
                    'name': name,
                    'line': line_ref,
                },
                'geometry': {'type': 'Point', 'coordinates': [lon, lat]},
            }
        )
    return {'type': 'FeatureCollection', 'features': features} if features else None


def write_asset(data: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2))
    print(f"Updated {path}")


def main() -> None:
    parser = argparse.ArgumentParser(description='Rebuild metro assets')
    parser.add_argument('--offline', action='store_true', help='Skip Overpass fetch and use default data')
    args = parser.parse_args()

    # Process lines
    lines_data = DEFAULT_LINES
    if not args.offline:
        try:
            print("Fetching metro lines...")
            lines_response = fetch_overpass(LINES_QUERY)
            converted = convert_lines(lines_response)
            if converted:
                lines_data = converted
        except Exception as err:
            print(f"Failed to fetch lines: {err}", file=sys.stderr)
    write_asset(lines_data, LINE_ASSET)

    # Process stations
    stations_data = DEFAULT_STATIONS
    if not args.offline:
        try:
            print("Fetching metro stations...")
            stations_response = fetch_overpass(STATIONS_QUERY)
            converted = convert_stations(stations_response)
            if converted:
                stations_data = converted
        except Exception as err:
            print(f"Failed to fetch stations: {err}", file=sys.stderr)
    write_asset(stations_data, STATION_ASSET)


if __name__ == '__main__':
    main()
