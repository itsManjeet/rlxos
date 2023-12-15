variables:
  strip: false
post-script: |
  cat > %{install-root}/info << "EOF"
  id: %{id}
  version: %{version}
  about: %{about}
  EOF

  install -vDm0755 %{libdir}/appimagekit/AppRun -t %{install-root}
  %{prepare-appimage}

  

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

  mkdir -p AppDir/
  mv %{install-root}/* AppDir/

  appimagetool ./AppDir/ %{install-root}/%{id}-%{version}.app