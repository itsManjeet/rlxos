# Syntax
Source try to be as mimimal as possible to be more easy and understandable


## Assign
Source variables are immutable and create new value on every assignation. Allocated data of value will clear after the 
deleted of last unassignation.

```
// declare a new value with := or =
x := 5;
// type independent
x = "hello";

x = true;

// array can holds value of multiple types
d := ["hello", 1, true, 1.1, func (a, b) {
    ret true;
}];

// method declaration
add := func (a, b) {
    ret a + b;
};
```

## Loop
Source provide single keyword `for` to provide multiple loop types
- iteration using range

```
for i in range(10) {
    println(i);
}
```

- while loop untile condition is true

```
for true {
    println("hey");
}
```


## Conditions
Source uses the minimal and traditional `if` `else` statements for conditions

```
x := 5;
if x < 1 {
    println(x, " < 5");
} else if x == 5 {
    println(x, " == 5");
} else {
    println(x, " else this");
}
```

## Method Block and Call
Source methods are lambda values that can be treated as any other value i.e can be stored in array or dict

```
add := func (a, b) {
    y := 2;
    ret a + b;
};

println(add(5, 6));
```

## Array
Source array can holds value of multiple types in same array, holds the type `arr`

```
array := ["hey", 5, true, 5.5, {"hello": "world"}, func (a) {
    ret a + 10;
}];


append(array, "another value");
pop(array);

array = array[1:3];
array[2] = true; 

```

## Dictionary
Source dictionary are hashmap of string and value, with some methods it will work like a object

```
d := {
    "hello" : "world",
    "hey" : true,
    "fc " func (a, b) {
        ret a - b;
    }
};

println(d["hello"]);

for i in range(keys(d)) {
    println(i, d[i]);
}

d.hey = false;

d["fc"](5, 6);

```

## Objects
Source objects are just dictionary with some special methods

```
Complex := func (real, img) {

    self := {};

    self.real := real;
    self.img := img;

    self.__eq__ := func (other) {
        ret self.real == other.real && self.img == other.img;
    };

    self.__str__ := func () {
        ret str(self.real) + " i" + str(self.img);
    };

    self.__type__ := func () {
        ret "__complex__";
    };
    
    ret self;

comp := Complex(5, 6);

comp_2 := Complex(8, 2);

println(comp + comp_2);
}
```
