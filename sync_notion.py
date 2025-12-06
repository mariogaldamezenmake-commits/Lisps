import os
import requests
import json
import sys
import glob
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Constants
NOTION_TOKEN = os.getenv("NOTION_TOKEN")
PAGE_ID = os.getenv("NOTION_PAGE_ID")
DB_VERSIONES_ID = "39dcbc91-7ecb-43be-bd63-b3c5d8032f1b"
DB_IDEAS_ID = "2bd1e155-833d-818d-8784-c758e32caf17"

HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28"
}

class NotionManager:
    def __init__(self):
        if not NOTION_TOKEN:
            print("Error: NOTION_TOKEN is not set in .env")
            sys.exit(1)

    def query_database(self, database_id, filter_criteria=None):
        """Query a database and return results."""
        url = f"https://api.notion.com/v1/databases/{database_id}/query"
        payload = {}
        if filter_criteria:
            payload["filter"] = filter_criteria
            
        results = []
        has_more = True
        start_cursor = None

        while has_more:
            if start_cursor:
                payload["start_cursor"] = start_cursor
            
            response = requests.post(url, headers=HEADERS, json=payload)
            if response.status_code == 200:
                data = response.json()
                results.extend(data["results"])
                has_more = data["has_more"]
                start_cursor = data["next_cursor"]
            else:
                print(f"Error querying DB {database_id}: {response.status_code}")
                # print(response.text)
                break
        return results

    def create_page(self, database_id, properties):
        """Create a new page in a database."""
        url = "https://api.notion.com/v1/pages"
        payload = {
            "parent": {"database_id": database_id},
            "properties": properties
        }
        response = requests.post(url, headers=HEADERS, json=payload)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error creating page: {response.status_code}")
            print(response.text)
            return None

    def update_page(self, page_id, properties):
        """Update an existing page."""
        url = f"https://api.notion.com/v1/pages/{page_id}"
        payload = {"properties": properties}
        response = requests.patch(url, headers=HEADERS, json=payload)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error updating page: {response.status_code}")
            print(response.text)
            return None
    
    def update_database_schema(self, database_id, properties):
        """Add or update properties in the database schema."""
        url = f"https://api.notion.com/v1/databases/{database_id}"
        payload = {"properties": properties}
        response = requests.patch(url, headers=HEADERS, json=payload)
        if response.status_code == 200:
            print(f"Schema updated for DB {database_id}")
            return response.json()
        else:
            print(f"Error updating schema for {database_id}: {response.status_code}")
            # print(response.text)
            return None

class CatalogSync:
    def __init__(self):
        self.notion = NotionManager()
        self.root_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Cache for project IDs to avoid repeated queries
        self.project_cache = {}

    def ensure_schema(self):
        """Ensures Databases have the necessary properties."""
        print("Verifying Database Schema...")
        
        # Ideas DB Schema
        ideas_props = {
            "Estado": {
                "select": {
                    "options": [
                        {"name": "Idea", "color": "yellow"},
                        {"name": "En Desarrollo", "color": "blue"},
                        {"name": "Validación", "color": "purple"},
                        {"name": "Estable", "color": "green"},
                        {"name": "Archivado", "color": "gray"}
                    ]
                }
            },
            "Prioridad": {
                "select": {
                    "options": [
                        {"name": "Alta", "color": "red"},
                        {"name": "Media", "color": "orange"},
                        {"name": "Baja", "color": "blue"}
                    ]
                }
            },
            "Tags": {"multi_select": {}}
        }
        self.notion.update_database_schema(DB_IDEAS_ID, ideas_props)
        
        # Versions DB Schema
        # Note: We cannot easily create a relation via API to a specific DB without knowing its internal name or if it already exists linked differently.
        # We will assume 'Proyecto' relation exists or user has to link it manually once.
        # But we CAN add the 'Estado' select.
        versions_props = {
            "Estado": {
                "select": {
                    "options": [
                        {"name": "Alpha", "color": "orange"},
                        {"name": "Beta", "color": "blue"},
                        {"name": "Release", "color": "green"}
                    ]
                }
            }
        }
        self.notion.update_database_schema(DB_VERSIONES_ID, versions_props)

    def _get_or_create_project(self, project_name):
        """Finds the Idea/Project page ID, or creates it if missing."""
        if project_name in self.project_cache:
            return self.project_cache[project_name]

        # Query Ideas DB
        filter_criteria = {
            "property": "Feature", # Title property name in Ideas DB
            "title": {
                "equals": project_name
            }
        }
        results = self.notion.query_database(DB_IDEAS_ID, filter_criteria)
        
        if results:
            page_id = results[0]["id"]
            self.project_cache[project_name] = page_id
            return page_id
        else:
            # Create new Project
            print(f"Creating new Project/Idea: {project_name}")
            props = {
                "Feature": {"title": [{"text": {"content": project_name}}]},
                "Estado": {"select": {"name": "En Desarrollo"}},
                "Descripción": {"rich_text": [{"text": {"content": "Proyecto generado automáticamente"}}]}
            }
            resp = self.notion.create_page(DB_IDEAS_ID, props)
            if resp:
                page_id = resp["id"]
                self.project_cache[project_name] = page_id
                return page_id
        return None

    def get_local_lisps(self):
        """Scan directory for .lsp files."""
        lisps = []
        for root, dirs, files in os.walk(self.root_dir):
            for file in files:
                if file.lower().endswith(".lsp"):
                    full_path = os.path.join(root, file)
                    rel_path = os.path.relpath(full_path, self.root_dir)
                    
                    project_name = self._determine_project(rel_path)
                    version = self._extract_version(file, rel_path)
                    stats = os.stat(full_path)
                    mod_time = datetime.fromtimestamp(stats.st_mtime).isoformat()
                    
                    changelog = self._extract_changelog(full_path)

                    lisps.append({
                        "name": file,
                        "path": rel_path,
                        "project": project_name,
                        "version": version,
                        "last_modified": mod_time,
                        "changelog": changelog
                    })
        return lisps

    def _extract_changelog(self, file_path):
        """Extracts checking for 'Novedades', 'Cambios' or 'Descripción' in file header."""
        changelog = ""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()[:50] # Check first 50 lines
                
            capturing = False
            captured_lines = []
            
            for line in lines:
                line = line.strip()
                # Start capturing
                if ";;;" in line and any(k in line for k in ["Novedades", "Cambios", "Features", "Descripción"]):
                    capturing = True
                    # clean line
                    cleaned = line.replace(";;;", "").strip()
                    if ":" in cleaned:
                        cleaned = cleaned.split(":", 1)[1].strip()
                    if cleaned: captured_lines.append(cleaned)
                    continue
                
                # Continue capturing if valid comment
                if capturing:
                    if line.startswith(";;;"):
                        cleaned = line.replace(";;;", "").strip()
                        if not any(k in line for k in ["Autor", "Requisito"]): # Stop keywords
                            if cleaned: captured_lines.append(cleaned)
                    else:
                        break # Stop at non-comment or empty line
                        
            changelog = "\n".join(captured_lines)
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
        
        return changelog

    def _determine_project(self, path):
        parts = path.split(os.sep)
        if len(parts) > 1:
            top_folder = parts[0]
            if top_folder == "Lisp_pozos": return "Pozos"
            if top_folder == "Lisp_Encaje_Planos": return "Encaje Planos"
            if top_folder == "Lisp_Gabinete_Nivel_Digital": return "Nivel Digital"
        return "General"

    def _extract_version(self, filename, path):
        if "v1.0" in filename or "version1.0" in path: return "v1.0"
        if "v1.2" in filename or "version1.2" in path: return "v1.2"
        if "v1.5" in filename or "version1.5" in path: return "v1.5"
        if "v2.0" in filename or "version2.0" in path: return "v2.0"
        if "v2.1" in filename or "version2.1" in path: return "v2.1"
        if "v3.0" in filename or "version3.0" in path: return "v3.0"
        if "v3.5" in filename or "version3.5" in path: return "v3.5"
        if "Manual" in path: return "Manual"
        return "Unknown"

    def sync(self):
        self.ensure_schema()
        
        print("Scanning local files...")
        local_files = self.get_local_lisps()
        print(f"Found {len(local_files)} LISP files.")

        print("Fetching existing versions...")
        existing_records = self.notion.query_database(DB_VERSIONES_ID)
        
        existing_map = {}
        for r in existing_records:
            try:
                title_prop = r["properties"]["Name"]["title"]
                if title_prop:
                    name = title_prop[0]["plain_text"]
                    existing_map[name] = r["id"]
            except KeyError:
                continue

        for lisp in local_files:
            # 1. Links to Project
            project_id = self._get_or_create_project(lisp["project"])
            
            # 2. Prepare Properties
            props = {
                "Name": {"title": [{"text": {"content": lisp["name"]}}]},
                "Versión": {"rich_text": [{"text": {"content": lisp["version"]}}]},
                "Notas técnicas": {"rich_text": [{"text": {"content": f"Path: {lisp['path']}"}}]},
                "Fecha": {"date": {"start": lisp["last_modified"]}}
            }
            
            # Add Changelog if exists
            if lisp.get("changelog"):
                 props["Cambios principales"] = {"rich_text": [{"text": {"content": lisp["changelog"][:2000]}}]}

            # Add Relation if we found a project
            if project_id:
                props["Proyecto"] = {"relation": [{"id": project_id}]}

            if lisp["name"] in existing_map:
                print(f"Updating {lisp['name']} (Project: {lisp['project']})...")
                self.notion.update_page(existing_map[lisp["name"]], props)
            else:
                print(f"Creating {lisp['name']} (Project: {lisp['project']})...")
                self.notion.create_page(DB_VERSIONES_ID, props)

    def add_idea(self, title, description):
        props = {
            "Feature": {"title": [{"text": {"content": title}}]},
            "Descripción": {"rich_text": [{"text": {"content": description}}]},
            "Estado": {"select": {"name": "No iniciado"}} 
        }
        resp = self.notion.create_page(DB_IDEAS_ID, props)
        if resp:
            print(f"Idea '{title}' added successfully!")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        manager = CatalogSync()
        
        if cmd == "update-catalog":
            manager.sync()
        elif cmd == "add-idea" and len(sys.argv) > 3:
            manager.add_idea(sys.argv[2], sys.argv[3])
        else:
            print("Usage:")
            print("  python sync_notion.py update-catalog")
            print("  python sync_notion.py add-idea 'Title' 'Description'")
    else:
        print("Usage: python sync_notion.py [update-catalog|add-idea]")
