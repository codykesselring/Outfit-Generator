from PIL import Image
import random
import os

# Paths
BASE_IMAGE_PATH = "base_image.png"
CLOTHES_FOLDER = "clothes/"

# Base image dimensions
BASE_IMAGE_WIDTH = 403
BASE_IMAGE_HEIGHT = 744

# Load base image (your body image)
base_image = Image.open(BASE_IMAGE_PATH).convert("RGBA")

# Load clothing items from subfolders
clothing_items = {
    "tops": [],
    "bottoms": []
}

# Scan subdirectories for clothing items
for category in clothing_items.keys():
    category_path = os.path.join(CLOTHES_FOLDER, category)
    if os.path.exists(category_path):
        clothing_items[category] = [
            Image.open(os.path.join(category_path, f)).convert("RGBA")
            for f in os.listdir(category_path) if f.endswith(".png")
        ]

# Function to resize and position clothes
def prepare_clothes(clothing_items, base_size):
    """Resize clothing items to fit appropriate regions on the body."""
    positions = {
        "tops": (120, -100),     # Position of tops (x, y) on the base image
        "bottoms": (170, 540)   # Position of bottoms
    }
    
    sizes = {
        "tops": (1100,1500),     # Size (width, height) of tops
        "bottoms": (1000, 1270)   # Size of bottoms
    }
    
    prepared_clothes = {}
    for category, items in clothing_items.items():
        prepared_clothes[category] = []
        for item in items:
            resized_item = item.resize(sizes[category], Image.Resampling.LANCZOS)
            prepared_clothes[category].append((resized_item, positions[category]))
    
    return prepared_clothes

# Overlay clothing on the base image
def generate_random_outfit(base_image, prepared_clothes):
    outfit_image = base_image.copy()
    
    # Randomly choose one item from each category
    for category, items in prepared_clothes.items():
        if items:  # Ensure category has items
            item, position = random.choice(items)  # Randomly pick a clothing item and its position
            # Paste clothing onto the base image at the specified position
            outfit_image.paste(item, position, item)
    
    return outfit_image

prepared_clothes = prepare_clothes(clothing_items, base_image.size)
outfit = generate_random_outfit(base_image, prepared_clothes)
outfit.show()
