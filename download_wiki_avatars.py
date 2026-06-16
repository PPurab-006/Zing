import json
import os
import urllib.request
import urllib.parse
import ssl
import time

def get_wiki_image(title):
    url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=pageimages&format=json&pithumbsize=500"
    req = urllib.request.Request(url, headers={'User-Agent': 'ZingAppAvatarFetcher/1.0 (purab@example.com) Python-urllib/3.x'})
    context = ssl._create_unverified_context()
    
    try:
        with urllib.request.urlopen(req, context=context, timeout=5) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            for page_id, page_info in pages.items():
                if 'thumbnail' in page_info:
                    return page_info['thumbnail']['source']
    except Exception as e:
        print(f"    Wiki API Exception for {title}: {e}")
    return None

def download_image(url, save_path):
    req = urllib.request.Request(url, headers={'User-Agent': 'ZingAppAvatarFetcher/1.0'})
    context = ssl._create_unverified_context()
    with urllib.request.urlopen(req, context=context, timeout=10) as response:
        with open(save_path, 'wb') as out_file:
            out_file.write(response.read())

def main():
    creators_file = 'assets/data/creators.json'
    avatars_dir = 'assets/images/avatars/'
    
    os.makedirs(avatars_dir, exist_ok=True)
    
    with open(creators_file, 'r', encoding='utf-8') as f:
        creators = json.load(f)
        
    updated = False
    
    wiki_titles = {
        "markiplier": "Markiplier",
        "technoblade": "Technoblade",
        "jacksepticeye": "Jacksepticeye",
        "mrbeast": "MrBeast",
        "vanossgaming": "VanossGaming",
        "pewdiepie": "PewDiePie",
        "dream": "Dream_(YouTuber)",
        "tommyinnit": "TommyInnit",
        "elrubius": "El_Rubius",
        "carryminati": "CarryMinati",
        "bbkiVines": "Bhuvan_Bam",
        "mariana": "Mariana_Nolasco",
        "xqc": "xQc",
        "valkyrae": "Valkyrae",
        "pokimane": "Pokimane",
        "ludwig": "Ludwig_Ahgren",
        "ninja": "Ninja_(gamer)",
        "shroud": "Shroud_(gamer)",
        "sykkuno": "Sykkuno",
        "ishowspeed": "IShowSpeed",
        "lilypichu": "LilyPichu",
        "mizkif": "Mizkif",
        "kalam": "A._P._J._Abdul_Kalam",
        "kobe": "Kobe_Bryant",
        "malala": "Malala_Yousafzai",
        "dantdm": "DanTDM",
        "penguinz0": "Cr1TiKaL",
        "mkbhd": "Marques_Brownlee",
        "ibai": "Ibai_Llanos",
        "kurzgesagt": "Kurzgesagt"
    }
    
    for creator in creators:
        c_id = creator['id']
        name = creator['name']
        
        avatar_path = f"{avatars_dir}{c_id}.jpg"
        
        if creator.get('avatar_asset') == avatar_path and os.path.exists(avatar_path):
            continue
            
        print(f"Fetching image for {name}...")
        
        wiki_title = wiki_titles.get(c_id, name)
        img_url = get_wiki_image(wiki_title)
        
        if img_url:
            try:
                download_image(img_url, avatar_path)
                creator['avatar_asset'] = avatar_path
                updated = True
                print(f"  Saved {avatar_path} from Wikipedia")
            except Exception as e:
                print(f"  Failed to download Wikipedia image for {name}: {e}")
        else:
            print(f"  No image results for {name} on Wikipedia")
            
        time.sleep(0.5) 
        
    if updated:
        with open(creators_file, 'w', encoding='utf-8') as f:
            json.dump(creators, f, indent=2, ensure_ascii=False)
        print("Updated creators.json")

if __name__ == '__main__':
    main()
