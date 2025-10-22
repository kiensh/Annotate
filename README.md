<div align="center">
  <img alt="logo" width="120" src="https://github.com/user-attachments/assets/f994edf4-c4be-46d2-a946-47d728171ffd" />
  <h1>Annotate</h1>
</div>

 <p align="center">
  <strong>A lightweight, keyboard-driven screen annotation tool for macOS that allows you to quickly draw, highlight, and annotate anything on your screen.</strong>
</p>

![annotate](https://github.com/user-attachments/assets/16baefb6-9fad-4702-9233-2991992ad030)

## ❓ Why?

Sometimes you need to emphasize a part of your screen or share ideas visually, and Annotate fills that gap with a simple, efficient interface. It enables real-time screen annotations using tools like pen, arrow, highlighter, rectangle, circle, counter, and text—perfect for highlighting and explaining concepts during presentations, live demos, or teaching sessions where visual annotations enhance understanding and clarity.

## ✨ Features

- 🎨 **Drawing Tools**:
  - ✒️ **Pen** tool for freehand drawing.
  - ➡️ **Arrow** tool for directional indicators.
  - 📏 **Line** tool for straight lines.
  - 🟨 **Highlighter** for emphasizing content.
  - 🔲 **Rectangle** shapes for boxing content.
  - ⭕ **Circle** shapes for highlighting areas.
  - 🔢 **Counter** tool for adding sequential numbered circles.
  - 📝 **Text** annotations with drag & edit support.
  - 👆 **Select** tool for moving and managing objects.
- 🎯 **Selection & Manipulation**:
  - Select single or multiple objects
  - Move objects by dragging
  - Delete selected objects
  - Rectangle selection to select multiple objects at once
  - Shift+Click to add/remove objects from selection
- ✨ **Fade/Persist Mode:** Control whether annotations fade out after a duration or persist on the screen.
- 📌 **Always-On Mode:** Display annotations persistently without user interaction.
- 🌈 **Color Picker:** Easily select and persist your preferred color.
- ↕️ **Line Width Control:** Adjust line thickness with an interactive picker or Command+Scroll wheel.
- ⬛ **Board**: Toggle whiteboard or blackboard based on system appearance.
- 🎛️ **Menu Bar Integration:** Quick access via a status icon.
- 🧹 **Auto-Clear Option:** Automatically clear all drawings when toggling the overlay.
- ⌨️ **Keyboard Shortcuts:** Switch between modes and toggle the overlay with customizable keyboard shortcuts.
- ⚡ **Global Hotkey:** Toggle Annotate with a global shortcut.
- 🔄 **Auto-Updates:** Automatic update checking with secure, cryptographically signed updates.

## 📦 Installation

### Download Release

1. **Download the Application:**

   - Go to [latest release](https://github.com/epilande/Annotate/releases/latest) page.
   - Download the `Annotate-x.x.x.dmg` file for easy installation, or `Annotate-x.x.x.zip` for manual installation.

2. **Install the Application:**

   **Using DMG (Recommended):**
   - Open the downloaded `Annotate-x.x.x.dmg` file.
   - Drag the `Annotate.app` into your **Applications** folder.

   **Using ZIP:**
   - Unzip the downloaded `Annotate-x.x.x.zip` file.
   - Drag the `Annotate.app` file into your **Applications** folder.

3. **Run the Application:**

   - Open your **Applications** folder and double-click `Annotate.app` to launch it.

> [!NOTE]
> Make sure your macOS version is 15 or later.
>
> The app is code-signed and notarized for macOS Gatekeeper compatibility.

### Build from Source

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/epilande/Annotate
   ```

2. **Open the Project in Xcode:**

   ```sh
   cd Annotate
   open Annotate.xcodeproj
   ```

3. **Build and Run:**
   - Ensure you have the latest version of Xcode installed.
   - Select your target macOS version, then build and run the project in Xcode.

## 🚀 Quick Start

1. Launch Annotate.
2. Press the global hotkey (configurable in Settings) to toggle the overlay.
3. Start annotating with the default pen tool.
4. Press <kbd>Esc</kbd> to exit the overlay.

> [!TIP]
> The application provides a menu bar item that lets you select tools, choose colors, and perform actions like undo and redo.
> It also shows the application's active state, current color selection, tool, and mode.

<img width="250" alt="image" src="https://github.com/user-attachments/assets/40a94d67-29f1-49a6-9a3a-453d7f3d89e1" />

## 🎮 Usage

### Keyboard Shortcuts

> [!TIP]
> All shortcuts are **left-hand optimized** for efficient mouse + keyboard workflow! All tool shortcuts can be customized in Settings.

#### 🎨 Drawing Tools (Top Row: Q-W-E-R-T)

| Key | Tool | Memory Hint | Description |
|-----|------|-------------|-------------|
| <kbd>Q</kbd> | **Pen** | **Q**uick drawing | Freehand drawing (most used, top-left position) |
| <kbd>W</kbd> | **Line** | **W**all or **W**ire | Draw straight lines |
| <kbd>E</kbd> | **Highlighter** | **E**mphasize text | Highlight areas with semi-transparent brush |
| <kbd>R</kbd> | **Rectangle** | **R**ectangle ✓ | Draw rectangles (hold <kbd>Option</kbd> for center) |
| <kbd>T</kbd> | **Text** | **T**ext ✓ | Add text annotations |

#### 🔧 Tools & Actions (Middle Row: A-S-D)

| Key | Tool | Memory Hint | Description |
|-----|------|-------------|-------------|
| <kbd>A</kbd> | **Arrow** | **A**rrow ✓ | Draw directional arrows |
| <kbd>S</kbd> | **Line Width** | **S**troke / **S**ize | Open line width picker |
| <kbd>D</kbd> | **Counter** | **D**igit / **D**ot | Add sequential numbered circles (1, 2, 3...) |

#### 🎯 Selection & Pickers (Bottom Row: X-C-V-B)

| Key | Tool | Memory Hint | Description |
|-----|------|-------------|-------------|
| <kbd>X</kbd> | **Color Picker** | Mi**X** colors | Open color selection menu |
| <kbd>C</kbd> | **Circle** | **C**ircle ✓ | Draw circles (hold <kbd>Option</kbd> for center) |
| <kbd>V</kbd> | **Select** | **V**isual mode | Select, move, and manage objects |
| <kbd>B</kbd> | **Board** | **B**oard ✓ | Toggle whiteboard/blackboard |

#### ⚡ Quick Actions

| Shortcut | Action | Description |
|----------|--------|-------------|
| <kbd>Space</kbd> | **Toggle Fade Mode** | Switch between fade and persist modes |
| <kbd>Delete</kbd> | **Delete** | Remove selected objects or most recent annotation |
| <kbd>Option</kbd> + <kbd>Delete</kbd> | **Clear All** | Remove all annotations |
| <kbd>Command</kbd> + <kbd>Z</kbd> | **Undo** | Undo the last action |
| <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd> | **Redo** | Redo the last undone action |
| Mouse Backward Button | **Undo** | Undo the last action (mouse button 3) |
| Mouse Forward Button | **Redo** | Redo the last undone action (mouse button 4) |
| <kbd>Command</kbd> + <kbd>Scroll</kbd> | **Adjust Width** | Quickly change line width |
| <kbd>Shift</kbd> (while drawing) | **Constrain** | Lines: 45° angles; Pen/Highlighter: straight |

#### 🪟 Overlay Controls

| Shortcut | Action | Description |
|----------|--------|-------------|
| Custom (Settings) | **Toggle Overlay** | Show or hide the annotation overlay |
| Custom (Settings) | **Always-On Mode** | Persistent, non-interactive display |
| <kbd>Esc</kbd> or <kbd>Command</kbd> + <kbd>W</kbd> | **Close** | Closes the annotation overlay |
| <kbd>Shift</kbd> + <kbd>Esc</kbd> | **Switch Mode** | Close interactive → enable always-on |
| <kbd>Enter</kbd> or <kbd>Esc</kbd> (in text) | **Finalize Text** | Complete text input |

#### 🎹 Visual Keyboard Layout

All shortcuts are **left-hand optimized** for efficient mouse + keyboard workflow:

```
Left-Hand QWERTY Layout:
┌─────┬─────┬─────┬─────┬─────┐
│     │     │     │     │     │
├─────┼─────┼─────┼─────┼─────┤  ← Top Row: Drawing Tools
│  Q  │  W  │  E  │  R  │  T  │    (most frequently used)
│ Pen │Line │High │Rect │Text │
├─────┼─────┼─────┼─────┼─────┤  ← Middle Row: Tools & Actions
│  A  │  S  │  D  │     │     │    (frequently used)
│Arrow│Width│Cntr │     │     │
├─────┼─────┼─────┼─────┼─────┤  ← Bottom Row: Selection & Pickers
│     │  X  │  C  │  V  │  B  │    (utility tools)
│     │Color│Circ │Slct │Brd  │
└─────┴─────┴─────┴─────┴─────┘

Legend:
  High = Highlighter    Slct = Select
  Rect = Rectangle      Cntr = Counter
  Circ = Circle         Brd = Board
  Width = Line Width
```

**💡 Memory Techniques:**

1. **First Letter Match** (easy to remember): **A**rrow, **R**ectangle, **C**ircle, **T**ext, **B**oard
2. **Top Row** = Most used drawing tools (Q/W/E/R/T like typing start)
3. **Q = Quick** = Pen (most used tool in top-left corner, easiest to reach)
4. **Middle Row** = Secondary actions and adjustments
5. **Bottom Row** = Pickers and special tools
6. **Mnemonics**:
   - **W** = **W**all/**W**ire (straight lines)
   - **E** = **E**mphasize (highlighter)
   - **S** = **S**troke/**S**ize (line width)
   - **D** = **D**igit/**D**ot (counter)
   - **X** = Mi**X** (color picker)
   - **V** = **V**isual mode (like Vim's visual mode for selection)

> [!NOTE]
> This layout follows the natural hand position on QWERTY keyboards, minimizing hand movement while keeping your right hand on the mouse!

### Drawing Tools

#### Pen & Highlighter

- Click and drag to draw freehand lines
- Pen creates solid lines while highlighter creates semi-transparent, thicker strokes
- Hold <kbd>Shift</kbd> while drawing to constrain to a perfectly straight line at 45° angle increments (0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°)
- Adjust line thickness using the Line Width Picker or <kbd>Command</kbd> + <kbd>Scroll</kbd> for quick adjustments

#### Line Width Control

Annotate provides flexible line width control:

- **Interactive Picker**: Press <kbd>s</kbd> or select "Line Width" from the menu bar to open a picker with:
  - Visual line preview showing the current thickness
  - Slider for precise width adjustment (0.5px to 20px)
  - Real-time feedback as you adjust
- **Quick Adjustment**: Hold <kbd>Command</kbd> and scroll your mouse wheel to quickly adjust line width
  - Scroll up to increase thickness
  - Scroll down to decrease thickness
  - Visual feedback appears at the bottom center showing current width and a preview line
- **Smart Scaling**: Arrowhead sizes automatically scale proportionally with line width for better visual balance

> [!TIP]
> Line width settings are persisted across sessions and apply to all drawing tools (pen, arrow, line, rectangle, circle).

#### Shapes (Rectangle, Circle)

- Click and drag to create shapes
- Hold <kbd>Option</kbd> while drawing rectangles or circles to expand from the center point

#### Arrow & Line

- Click and drag to create directional arrows or straight lines
- Hold <kbd>Shift</kbd> while drawing to snap to 45° angle increments for perfectly horizontal, vertical, or diagonal lines
- Arrows automatically create arrowheads pointing in the direction of the drag
- Lines create simple straight connections between two points

#### Text Annotations

- Click to place a text annotation
- Type your text and press <kbd>Enter</kbd> or <kbd>Esc</kbd> to finalize
- Double-click any text annotation to edit its content
- Click and drag to reposition text

#### Counter Tool

- Click anywhere to add sequential numbered circles (1, 2, 3...)
- Numbers increment automatically with each click

#### Select Tool

The Select tool allows you to manipulate existing annotations with precision:

- **Select Objects**: Press <kbd>v</kbd> to enter select mode
  - Click on objects to select them (lines, arrows, shapes, text, etc.)
  - Circles and rectangles must be clicked on their edges
  - A blue dashed bounding box appears around selected objects
  
- **Multiple Selection**:
  - **Rectangle Selection**: Click and drag on empty space to draw a selection rectangle
    - All objects inside or touching the rectangle are selected
  - **Shift+Click**: Hold <kbd>Shift</kbd> and click objects to add/remove them from selection
  - **Shift+Rectangle**: Hold <kbd>Shift</kbd> while drawing a rectangle to add to existing selection
  
- **Move Objects**:
  - Click anywhere inside the blue bounding box and drag to move selected objects
  - Multiple selected objects move together, maintaining their relative positions
  
- **Delete Selected**:
  - Press <kbd>Delete</kbd> to remove all selected objects
  - Use <kbd>Command</kbd> + <kbd>Z</kbd> to undo deletions
  
- **Clear Selection**: Click on empty space (without <kbd>Shift</kbd>) to deselect all objects

> [!TIP]
> The select tool makes it easy to correct mistakes, reposition elements, and build complex diagrams by moving groups of objects together.

### Drawing Modes

Toggle between modes with the <kbd>Space</kbd> key.

#### Fade Mode

In fade mode, annotations gradually disappear after a few seconds, keeping your screen clean while allowing for temporary emphasis.

#### Persist Mode

In persist mode, annotations remain on screen until manually cleared, allowing you to build up complex annotations over time.

### Always-On Mode

Always-On Mode displays your annotations persistently without any user interaction capability. This mode is ideal for presentations where you need important information visible without accidental modifications, reference displays with static guides or markers, and multi-screen setups where annotations remain on secondary monitors.

#### How to use:

1. Create your annotations in normal interactive mode
2. Toggle always-on mode via the global hotkey (configurable in Settings) or menu bar
3. Annotations become persistent and non-interactive
4. Use the same hotkey or menu option to exit always-on mode and resume editing

### Deletion Controls

- <kbd>Delete</kbd>: Removes the most recently added annotation.
- <kbd>Option</kbd> + <kbd>Delete</kbd>: Clear all annotations from the screen.

## ⚙️ Settings

Access the Settings panel from the menu bar icon or by pressing <kbd>Command</kbd> + <kbd>,</kbd>.

### General Settings

- **Annotate Hotkey**: Set a global keyboard shortcut to toggle Annotate.
- **Always-On Mode**: Set a global keyboard shortcut to toggle always-on mode.
- **Clear Drawings on Toggle**: Automatically clear all drawings when activating Annotate.
- **Hide Dock Icon**: Run Annotate in a more minimal mode without a dock icon.

### Keyboard Shortcuts

Customize keyboard shortcuts for all drawing tools by assigning individual shortcut keys for each tool (pen, arrow, highlighter, etc.).

<img width="472" alt="image" src="https://github.com/user-attachments/assets/37d3498b-baa8-4fa5-93b0-6d2f8cc9246d" />

## 🔄 Auto-Updates

Annotate includes automatic update checking powered by [Sparkle](https://sparkle-project.org/):

- **Automatic Checks**: The app checks for updates once per day.
- **Manual Check**: Select **Check for Updates...** from the menu bar or use the About window.
- **Secure Updates**: All updates are cryptographically signed and verified before installation.

Updates are downloaded and installed seamlessly in the background. You'll be notified when a new version is available, with release notes and the option to install immediately or later.

