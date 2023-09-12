package utils

import (
	"log"
	"reflect"
)

func Merge(e1, e2 interface{}) interface{} {
	e1Value := reflect.ValueOf(&e1).Elem()
	e2Value := reflect.ValueOf(&e2).Elem()
	log.Println(e1Value, e2Value)

	for i := 0; i < e1Value.NumField(); i++ {
		field1 := e1Value.Field(i)
		field2 := e2Value.Field(i)

		if field1.Kind() == reflect.Slice {
			mergedSlice := reflect.AppendSlice(field1, field2)
			field1.Set(mergedSlice)
		} else if field1.Kind() == reflect.Map {
			mergedMap := reflect.MakeMap(field1.Type())
			for _, key := range field1.MapKeys() {
				mergedMap.SetMapIndex(key, field1.MapIndex(key))
			}
			for _, key := range field2.MapKeys() {
				mergedMap.SetMapIndex(key, field2.MapIndex(key))
			}
			field1.Set(mergedMap)
		} else {
			if field1.Interface() == reflect.Zero(field1.Type()) {
				field1.Set(field2)
			}
		}
	}

	return e1
}
