import urllib.request
try:
    urllib.request.urlretrieve("https://unavatar.io/youtube/markiplier", "markiplier_test.jpg")
    print("Success")
except Exception as e:
    print(f"Error: {e}")
