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
src=$PWD/src
errorfile=$(mktemp -u)
moddir=$(mktemp -d)
packdir=$(mktemp -d)
download=$(mktemp -d)
dir=$PWD
readList() {
	cat "$*" | awk '{print $1}'
}
insrc() {
	for f in $@ ;do
		echo -n "$src/$(basename $f) "
	done
	echo
}
zipMods="$(insrc $(readList $dir/modsSrc.txt))"
zipModpacks="$(insrc $(readList $dir/modpacksSrc.txt))"
waitX() {
	wait
	[ -f "$errorfile" ] && {
		echo "[ERROR]$(cat $errorfile)" 1>&2
		exit 1
	}
}
error(){
	echo "$*">>"$errorfile"
}
unZip() {
	7z x -r -o./ "$1" || unzip "$1" || return 1
}

(
	rm -rfv build/
	mkdir $dir/build
	touch $dir/build/modpack.txt
)&
cd $moddir
for mod in $(readList $dir/mods.txt) ;do
	(git clone --depth 1 "$mod" || error "运行git clone $mod失败")&
done
cd $packdir
for pack in $(readList $dir/modpacks.txt) ;do
	(git clone --depth 1 "$pack" || error "运行git clone $pack失败")&
done
cd $download
for file in $(readList $dir/modsWget.txt) ;do
	zipMods="$zipMods $download/$(basename $file)"
	(wget "$file" || error "下载$file失败")&
done
for file in $(readList $dir/modpacksWget.txt) ;do
	zipModpacks="$zipModpacks $download/$(basename $file)"
	(wget "$file" || error "下载$file失败")&
done
cd $dir

waitX
cd $moddir
for zip in $zipMods ;do
	(unZip "$zip" || error "解压$zip失败")&
done
cd $packdir
for zip in $zipModpacks ;do
	(unZip "$zip" || error "解压$zip失败")&
done

waitX
cd $dir/build
for license in $packdir/*/LICENSE* $packdir/*/license* $packdir/*/README* $packdir/*/readme* ;do
	cp $license $(dirname $license)/*/ &
done

waitX
mv -vf $moddir/*/ $packdir/*/*/ ./ 2>/dev/null
rm -rvf $moddir/ $packdir/ $download/ $(find -name .git)

cd $dir/build
for d in $(ls $dir/d/) ;do
	(bash $dir/d/$d || error "运行bash $dir/d/$d失败")&
done

waitX
