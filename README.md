# 🍣 Sushi Dash Delivery — Godot 4 Project

## How to open this project
1. Download **Godot 4** from https://godotengine.org/download  
   (get the Standard version — NOT the Mono/C# one)
2. Unzip this folder somewhere on your computer
3. Open Godot → click **Import** → find this folder → select `project.godot`
4. Press **F5** (or the ▶ button) to play!

---

## Controls
| Key | Action |
|-----|--------|
| W A S D  or  Arrow Keys | Move the scooter |
| Mouse click + drag | Slice sushi in the mini-game |

---

## How the game works
1. Drive your scooter 🛵 to the **🏯 Restaurant** in the centre to pick up an order
2. Drive to the **🏠 customer's house** shown on the map
3. Play the **Sushi Slice mini-game** — slice as many sushi as you can before time runs out!
4. Earn points, money, and delivery credits, then go again!

---

## Files and what they do

```
sushi_simple/
│
├── project.godot          ← Godot opens this file
│
├── scripts/
│   ├── Global.gd          ← Shared variables (score, money, orders)
│   ├── MainMenu.gd        ← Title screen logic
│   ├── DeliveryMap.gd     ← Overworld: driving + picking up orders
│   └── SliceGame.gd       ← Mini-game: slicing sushi!
│
└── scenes/
    ├── MainMenu.tscn      ← Title screen layout
    ├── DeliveryMap.tscn   ← Overworld layout
    └── SliceGame.tscn     ← Mini-game layout
```

---

## Code concepts used (great for NCEA Level 1!)

| Concept | Where to find it |
|---------|-----------------|
| Variables (`var`) | Every script, e.g. `var lives = 3` |
| Constants (`const`) | Top of `SliceGame.gd` |
| If/else statements | `DeliveryMap.gd` → `check_arrival()` |
| For loops | `DeliveryMap.gd` → `spawn_customers()` |
| Functions (`func`) | Every script — each action is its own function |
| Dictionaries | `Global.gd` — each customer/sushi is a dictionary |
| Arrays / Lists | `Global.gd` — `customers`, `sushi_list`, `danger_list` |
| Random numbers | `SliceGame.gd` → `spawn_item()` |
| Autoload (singleton) | `Global.gd` — one place for shared data |
| Tweens (animation) | `MainMenu.gd`, `SliceGame.gd` |

---

## Mini-game scoring
| What you do | Effect |
|-------------|--------|
| Slice a sushi 🍣 | +10 to +20 points |
| Slice several in ONE swipe | Combo multiplier (x1.5, x2.0 …) |
| Slice 💣 Wasabi Bomb | -30 points + lose a life |
| Slice 🐡 Expired Fish | -20 points + lose a life |
| Slice 🌶 Hot Pepper | -25 points + lose a life |
| Let sushi fall off screen | Lose a life |
