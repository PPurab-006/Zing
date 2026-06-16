import json
import os
import urllib.request
from duckduckgo_search import DDGS
import time

def main():
    creators_file = 'assets/data/creators.json'
    avatars_dir = 'assets/images/avatars/'
    
    os.makedirs(avatars_dir, exist_ok=True)
    
    with open(creators_file, 'r', encoding='utf-8') as f:
        creators = json.load(f)
        
    updated = False
    
    for creator in creators:
        c_id = creator['id']
        name = creator['name']
        
        # Determine search query
        query = f"{name} youtuber flattering headshot portrait"
        if creator['category'] == 'streamer':
            query = f"{name} streamer flattering headshot portrait"
        elif creator['category'] == 'public_figure':
            query = f"{name} flattering headshot portrait"
            
        avatar_path = f"{avatars_dir}{c_id}.jpg"
        
        # If avatar already exists and is assigned, skip
        if creator.get('avatar_asset') == avatar_path and os.path.exists(avatar_path):
            continue
            
        print(f"Fetching image for {name}...")
        
        try:
            results = DDGS().images(query, max_results=3)
            if results:
                # Get the first working image
                success = False
                for res in results:
                    img_url = res['image']
                    try:
                        req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
                        with urllib.request.urlopen(req, timeout=5) as response:
                            with open(avatar_path, 'wb') as out_file:
                                out_file.write(response.read())
                        success = True
                        break
                    except Exception as e:
                        print(f"  Failed url {img_url}: {e}")
                        continue
                        
                if success:
                    creator['avatar_asset'] = avatar_path
                    updated = True
                    print(f"  Saved {avatar_path}")
                else:
                    print(f"  Failed to download any image for {name}")
            else:
                print(f"  No image results for {name}")
        except Exception as e:
            print(f"  Error searching for {name}: {e}")
            
        time.sleep(1) # be polite to DDG
        
    if updated:
        with open(creators_file, 'w', encoding='utf-8') as f:
            json.dump(creators, f, indent=2, ensure_ascii=False)
        print("Updated creators.json")

if __name__ == '__main__':
    main()
