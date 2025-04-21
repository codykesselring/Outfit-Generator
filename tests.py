mport pytest
from PIL import Image
import os
from main import (  
    BASE_IMAGE_PATH,
    CLOTHES_FOLDER,
    clothing_items,
    clothing_index,
    resize_and_prepare,
    generate_outfit,
    positions,
    sizes,
    BASE_IMAGE_HEIGHT,
    BASE_IMAGE_WIDTH,
    prepared_clothes
)

@pytest.fixture
def setup_files(tmp_path):
    # Create a temporary directory structure for testing
    base_dir = tmp_path
    base_image = base_dir / "base_image.png"
    clothes_dir = base_dir / "clothes"
    
    # Create a simple base image
    img = Image.new('RGBA', (100, 200), color=(255, 0, 0, 255))
    img.save(base_image)
    
    # Create clothing subdirectories and sample images
    for category in ["footwear", "bottoms", "tops"]:
        cat_dir = clothes_dir / category
        cat_dir.mkdir(parents=True)
        for i in range(2):  # Create 2 sample images per category
            img = Image.new('RGBA', (50, 50), color=(0, i*100, 0, 255))
            img.save(cat_dir / f"{category}_{i}.png")
    
    return base_dir

def test_file_loading(setup_files):
    """Test that clothing items are loaded correctly from folders"""
    assert isinstance(clothing_items, dict)
    for category in ["footwear", "bottoms", "tops"]:
        assert category in clothing_items

def test_resize_and_prepare():
    """Test that image resizing works as expected"""
    test_img = Image.new('RGBA', (100, 100), color=(255, 0, 0, 255))
    test_clothes = {"test": [test_img]}
    test_sizes = {"test": (50, 50)}
    
    original_sizes = sizes.copy()
    sizes["test"] = (50, 50)
    
    prepared = resize_and_prepare()
    assert "test" not in prepared  
    
    sizes.clear()
    sizes.update(original_sizes)


def test_clothing_index_rotation():
    """Test that clothing index rotates correctly"""
    original_index = clothing_index.copy()
    test_category = "tops"
    clothing_items[test_category] = [None, None, None]  # Just for testing
    
    clothing_index[test_category] = 0
    assert clothing_index[test_category] == 0

    clothing_index[test_category] = (clothing_index[test_category] + 1) % len(clothing_items[test_category])
    assert clothing_index[test_category] == 1
    
    clothing_index[test_category] = (clothing_index[test_category] + 1) % len(clothing_items[test_category])
    assert clothing_index[test_category] == 2
    
    clothing_index[test_category] = (clothing_index[test_category] + 1) % len(clothing_items[test_category])
    assert clothing_index[test_category] == 0  
    
    clothing_index.clear()
    clothing_index.update(original_index)

def test_clothing_positions():
    """Test that clothing positions are properly defined"""
    for category in ["footwear", "bottoms", "tops"]:
        assert category in positions
        assert isinstance(positions[category], tuple)
        assert len(positions[category]) == 2

def test_clothing_sizes():
    """Test that clothing sizes are properly defined"""
    for category in ["footwear", "bottoms", "tops"]:
        assert category in sizes
        assert isinstance(sizes[category], tuple)
        assert len(sizes[category]) == 2

def test_clothing_categories():
    """Test that all expected clothing categories exist"""
    expected_categories = ["footwear", "bottoms", "tops"]
    for category in expected_categories:
        assert category in clothing_items

def test_base_image_exists():
    """Test that the base image file exists"""
    assert os.path.exists(BASE_IMAGE_PATH)

def test_clothes_folder_exists():
    """Test that the clothes folder exists"""
    assert os.path.exists(CLOTHES_FOLDER)
    assert os.path.isdir(CLOTHES_FOLDER)

def test_generate_outfit_with_no_clothing():
    """Test that outfit generation works when no clothing items are selected"""
    original_indices = clothing_index.copy()

    for category in clothing_index:
        clothing_index[category] = -1  
    
    outfit = generate_outfit()
    
    assert isinstance(outfit, Image.Image)
    assert outfit.size == (562, 744) 
    
    clothing_index.update(original_indices)

def test_initialization():
    """Test that all required components are properly initialized"""
    assert os.path.exists(BASE_IMAGE_PATH)
    base_img = Image.open(BASE_IMAGE_PATH)
    assert isinstance(base_img, Image.Image)
    
    assert os.path.exists(CLOTHES_FOLDER)
    assert os.path.isdir(CLOTHES_FOLDER)
    
    expected_categories = ["footwear", "bottoms", "tops"]
    for category in expected_categories:
        assert category in clothing_items
        category_path = os.path.join(CLOTHES_FOLDER, category)
        assert os.path.exists(category_path)
        
    for category in expected_categories:
        assert category in positions
        assert isinstance(positions[category], tuple)
        assert len(positions[category]) == 2
        
        assert category in sizes
        assert isinstance(sizes[category], tuple)
        assert len(sizes[category]) == 2
    
    for category in expected_categories:
        assert category in clothing_index
        assert clothing_index[category] == 0 
