import tkinter as tk
from tkinter import Label, Button
from PIL import Image, ImageTk
import os

# Paths
BASE_IMAGE_PATH = "base_image.png"
CLOTHES_FOLDER = "clothes/"

# Load base image
base_image = Image.open(BASE_IMAGE_PATH).convert("RGBA")
BASE_IMAGE_WIDTH = 403
BASE_IMAGE_HEIGHT = 744
# Load clothing items from subfolders
clothing_items = {
    "footwear": [],
    "bottoms": [],
    "tops": []
}

for category in clothing_items.keys():
    category_path = os.path.join(CLOTHES_FOLDER, category)
    if os.path.exists(category_path):
        clothing_items[category] = [
            Image.open(os.path.join(category_path, f)).convert("RGBA")
            for f in os.listdir(category_path) if f.endswith(".png")
        ]

# Positions and sizes for layering
positions = {
    "footwear": (75, 215),
    "bottoms": (78, 220),
    "tops": (47, -40)
}

sizes = {
    "footwear": (415, 550),
    "bottoms": (415, 545),
    "tops": (475, 640)
}

# Track current selection index for each category
clothing_index = {category: 0 for category in clothing_items}

def resize_and_prepare():
    prepared_clothes = {}
    for category, items in clothing_items.items():
        prepared_clothes[category] = [
            item.resize(sizes[category], Image.Resampling.LANCZOS) for item in items
        ]
    return prepared_clothes

prepared_clothes = resize_and_prepare()

def generate_outfit():
    outfit_image = base_image.copy()
    for category, items in prepared_clothes.items():
        if items:
            index = clothing_index[category]
            item = items[index]
            position = positions[category]
            outfit_image.paste(item, position, item)
    return outfit_image

def update_outfit():
    outfit = generate_outfit()
    outfit_tk = ImageTk.PhotoImage(outfit)
    outfit_label.config(image=outfit_tk)
    outfit_label.image = outfit_tk

def next_clothing(category):
    if clothing_items[category]:
        clothing_index[category] = (clothing_index[category] + 1) % len(clothing_items[category])
        update_outfit()

# Create GUI
root = tk.Tk()
root.title("Clothing Selector")

# Display area
outfit = generate_outfit()
outfit_tk = ImageTk.PhotoImage(outfit)
outfit_label = Label(root, image=outfit_tk)
outfit_label.pack()

# Control buttons
for category in clothing_items.keys():
    Button(root, text=f"Next {category}", command=lambda c=category: next_clothing(c)).pack()

root.mainloop()
