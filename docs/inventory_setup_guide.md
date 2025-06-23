# Wyvernbox Inventory System Setup Guide

## ✅ Installation Complete
The Wyvernbox Inventory System has been installed and is ready to use!

## 🚀 Quick Setup Steps

### 1. Enable the Plugin
1. Open Godot Project Settings (`Project > Project Settings`)
2. Go to the `Plugins` tab
3. Find "Wyvernbox" and enable it
4. Restart Godot if prompted

### 2. Add Inventory to Player
1. Open your `Player.tscn` scene
2. Add an `Inventory` node as a child of the Player
3. In the Inspector, set the inventory size (e.g., 20 slots)

### 3. Add Inventory UI
1. Create a new scene for your inventory UI
2. Drag `addons/wyvernbox_prefabs/inventories/inventory.tscn` into your scene
3. Connect it to your player's inventory node

### 4. Add Ground Item Pickup
1. For the wedding ring, use `addons/wyvernbox_prefabs/ground_item_stack_view_2d.tscn`
2. Set the ItemType to the wedding ring resource we created
3. Place it in your level where players should find it

## 📋 Available Prefabs
Located in `addons/wyvernbox_prefabs/`:

- **Inventories:**
  - `inventory.tscn` - Basic inventory
  - `grid_inventory.tscn` - Grid-based (like Resident Evil)
  - `equipment_inventory.tscn` - For equippable items

- **UI Components:**
  - `tooltip.tscn` - Item tooltips
  - `grabbed_item_stack_view.tscn` - Drag and drop
  - `item_stack_view.tscn` - Individual item display

- **World Items:**
  - `ground_item_stack_view_2d.tscn` - 2D ground items
  - `ground_item_stack_view_3d.tscn` - 3D ground items

## 🎮 Player Integration
Your existing player movement and controls will work perfectly with Wyvernbox. The system uses signals for all interactions, so it won't interfere with your current setup.

## 📖 Documentation
Full documentation available at: https://github.com/don-tnowe/godot-wyvernbox-inventory

## 🔧 Wedding Ring Setup
A wedding ring ItemType has been created at `scenes/items/wedding_ring_item_type.tres` with:
- Quest item flags (can't be dropped)
- Single stack size (only one ring)
- Special wedding tags for easy identification

## ⚡ Quick Test
1. Enable the plugin
2. Open the example scene: `addons/wyvernbox_prefabs/inventories/inventory.tscn`
3. Run it to see the inventory in action!
