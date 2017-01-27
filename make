#!/bin/bash
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
	(git clone "$mod" || error "运行git clone $mod失败")&
done
cd $packdir
for pack in $(readList $dir/modpacks.txt) ;do
	(git clone "$pack" || error "运行git clone $pack失败")&
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
for zip in $zipMobpacks ;do
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
