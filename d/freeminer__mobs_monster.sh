#!/bin/bash
#Copyright (c) 2016 zaoqi  

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.

#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
cd mobs_monster
[ "$(sha1sum init.lua)" != "c5afc9aa0d86ef9013d213f8eb0c369633c4867a  init.lua" ] &&
  echo "【错误】freeminer::mobs_monster/init.lua被更新" 1>&2 && exit 1

(cat <<'EOF'
local path = minetest.get_modpath("mobs_monster")

-- Monsters

--dofile(path .. "/dirt_monster.lua") -- PilzAdam
--dofile(path .. "/dungeon_master.lua")
--dofile(path .. "/oerkki.lua")
--dofile(path .. "/sand_monster.lua")
--dofile(path .. "/stone_monster.lua")
--dofile(path .. "/tree_monster.lua")
--dofile(path .. "/lava_flan.lua") -- Zeg9
--dofile(path .. "/mese_monster.lua")
dofile(path .. "/spider.lua") -- AspireMint

print ("[MOD] Mobs Redo 'Monsters' loaded")
EOF
) >init.lua
