import os
import requests
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

NOTION_TOKEN = os.getenv("NOTION_TOKEN")
PAGE_ID = os.getenv("NOTION_PAGE_ID")

HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28"
}

def get_page_content():
    """Retrieves the blocks (content) of the Notion page."""
    if not PAGE_ID or PAGE_ID == "PUT_YOUR_PAGE_ID_HERE":
        print("Error: NOTION_PAGE_ID is not set in .env")
        return

    url = f"https://api.notion.com/v1/blocks/{PAGE_ID}/children"
    response = requests.get(url, headers=HEADERS)
    
    if response.status_code == 200:
        data = response.json()
        print("--- Page Content ---")
        for block in data["results"]:
            if block["type"] == "paragraph":
                text = block["paragraph"]["rich_text"]
                if text:
                    print(f"- {text[0]['plain_text']}")
    else:
        print(f"Error fetching page: {response.status_code}")
        print(response.text)

def add_update(text):
    """Adds a new paragraph block to the page."""
    if not PAGE_ID or PAGE_ID == "PUT_YOUR_PAGE_ID_HERE":
        print("Error: NOTION_PAGE_ID is not set in .env")
        return

    url = f"https://api.notion.com/v1/blocks/{PAGE_ID}/children"
    data = {
        "children": [
            {
                "object": "block",
                "type": "paragraph",
                "paragraph": {
                    "rich_text": [
                        {
                            "type": "text",
                            "text": {
                                "content": text
                            }
                        }
                    ]
                }
            }
        ]
    }
    
    response = requests.patch(url, headers=HEADERS, json=data)
    if response.status_code == 200:
        print("Successfully added update to Notion!")
    else:
        print(f"Error adding update: {response.status_code}")
        print(response.text)

def publish_version(version, summary, instructions):
    """Publishes a version update with summary and instructions."""
    if not PAGE_ID or PAGE_ID == "PUT_YOUR_PAGE_ID_HERE":
        print("Error: NOTION_PAGE_ID is not set in .env")
        return

    url = f"https://api.notion.com/v1/blocks/{PAGE_ID}/children"
    
    children = [
        {
            "object": "block",
            "type": "heading_2",
            "heading_2": {
                "rich_text": [{"type": "text", "text": {"content": f"Version {version}"}}]
            }
        },
        {
            "object": "block",
            "type": "heading_3",
            "heading_3": {
                "rich_text": [{"type": "text", "text": {"content": "Resumen"}}]
            }
        },
        {
            "object": "block",
            "type": "paragraph",
            "paragraph": {
                "rich_text": [{"type": "text", "text": {"content": summary}}]
            }
        },
        {
            "object": "block",
            "type": "heading_3",
            "heading_3": {
                "rich_text": [{"type": "text", "text": {"content": "Instrucciones"}}]
            }
        },
        {
            "object": "block",
            "type": "paragraph",
            "paragraph": {
                "rich_text": [{"type": "text", "text": {"content": instructions}}]
            }
        },
        {
            "object": "block",
            "type": "divider",
            "divider": {}
        }
    ]

    data = {"children": children}
    
    response = requests.patch(url, headers=HEADERS, json=data)
    if response.status_code == 200:
        print(f"Successfully published version {version} to Notion!")
    else:
        print(f"Error publishing: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "read":
            get_page_content()
        elif command == "write" and len(sys.argv) > 2:
            add_update(" ".join(sys.argv[2:]))
        elif command == "publish" and len(sys.argv) >= 5:
            # Usage: python sync_notion.py publish "v1.0" "Summary text" "Instructions text"
            publish_version(sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            print("Usage:")
            print("  python sync_notion.py read")
            print("  python sync_notion.py write 'Message'")
            print("  python sync_notion.py publish 'Version' 'Summary' 'Instructions'")
    else:
        print("Usage: python sync_notion.py [read|write|publish] ...")
