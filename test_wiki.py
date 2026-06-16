import urllib.request
import json
import ssl

def get_wiki_image(title):
    url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=pageimages&format=json&pithumbsize=500"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    context = ssl._create_unverified_context()
    
    try:
        with urllib.request.urlopen(req, context=context) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            for page_id, page_info in pages.items():
                if 'thumbnail' in page_info:
                    return page_info['thumbnail']['source']
    except Exception as e:
        print(e)
    return None

print("MrBeast:", get_wiki_image("MrBeast"))
print("Jacksepticeye:", get_wiki_image("Jacksepticeye"))
print("CarryMinati:", get_wiki_image("CarryMinati"))
