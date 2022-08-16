#!/usr/bin/gjs

const GLib = imports.gi.GLib;
const HERE = GLib.getenv("HERE");

imports.package.init({ name: "org.gnome.Characters",
                       version: "@@version@@",
                       prefix: HERE + "/usr",
                       libdir: HERE + "/usr/lib"});
imports.main.application_id = "org.gnome.Characters.Devel";
imports.package.run(imports.main);