strip: false
skip-libraries: >-
  libc.so*

prepare-appimage: ""
type: app
build-depends:
- components/appimagetool.yml
- components/zsync.yml
- components/gnupg.yml
- components/appstream.yml

post-script: |
  install -vDm0755 %{libdir}/appimagekit/AppRun -t %{install-root}
  %{prepare-appimage}

  [ -d %{install-root}/%{datadir}/glib-2.0/schemas/ ] && glib-compile-schemas %{install-root}/%{datadir}/glib-2.0/schemas/
  
  for i in help man doc gtk-doc ; do
    [ -d %{install-root}/%{datadir}/${i} ] && rm -rf %{install-root}/%{datadir}/${i}
  done

  find %{install-root}/ -type f -executable | xargs objdump -p | grep NEEDED | awk '{print $2}' >> required-libraries

  if [[ -n "%{skip-libraries}" ]] ; then
    skipped=""
    for i in %{skip-libraries}
    do
      skipped="$skipped -e $i"
    done
    FILTER="grep -v $skipped"
  else
    FILTER="cat"
  fi

  mkdir -p %{install-root}/%{libdir}
  for i in $(cat required-libraries | sort | uniq | ${FILTER}) ; do
    if [[ -e %{libdir}/$i ]] ; then
      cp %{libdir}/$i %{install-root}/%{libdir}
    elif [[ -e %{install-root}/%{libdir}/$i ]] ; then
      continue
    else
      echo "MISSING REQUIRED LIBRARY $i"
    fi
  done

  if [ "$(find %{install-root}/ -maxdepth 1 -type f -name '*.desktop' 2>/dev/null | wc -l)" -eq "0" ] ; then
    cp -v %{install-root}/%{datadir}/applications/*.desktop %{install-root}/
  fi
  
  if [ "$(find %{install-root}/ -maxdepth 1 -type f -name '*.svg' 2>/dev/null | wc -l)" -eq "0" ] ; then
    for i in $(find %{install-root}/%{datadir}/icons/ -name "*.png" -o -name "*.svg") ; do
      cp -v ${i} %{install-root}/
    done
  fi

  mkdir -p AppDir/
  mv %{install-root}/* AppDir/

  cd %{install-root}/
  appimagetool -nu "zsync|http://repo.rlxos.dev/apps/%{id}.app.zsync" %{build-root}/AppDir/ %{id}.app