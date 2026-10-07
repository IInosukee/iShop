# Script de Supérette en RageUI

## Dépendances
- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy recommandé, les anciennes versions restent compatibles)
- OneSync recommandé : il active la vérification de distance côté serveur (anti-triche)

## Installation
Ajouter `ensure iShop` dans le `server.cfg` (après `es_extended`).

## Config Simple
![image](https://user-images.githubusercontent.com/83782101/232259897-b5b3b5db-69a0-4891-843a-6101be9d50cb.png)

Pour ajouter un article, ajouter une entrée dans `Config.Shop` (`config.lua`) :
```lua
{
    label = "Sandwich", -- nom affiché dans le menu
    price = 8,          -- prix à l'unité
    item = "sandwich",  -- nom de l'item dans la base de données
},
```

Autres options : `InteractDistance`, `MaxBuyDistance`, `MaxQuantity`, `BlipLabel`.

> Le prix est toujours calculé par le serveur à partir de `config.lua` : un client ne peut pas imposer son propre prix.

## Crédits
Par IInosukee

## Nova-Dev
https://discord.gg/WzjTGUDaAA
