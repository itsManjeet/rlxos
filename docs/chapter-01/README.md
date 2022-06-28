# Introduction to rlxos

## What is rlxos?

rlxos (pronounced as relax or releax OS or r-l-x-O-S) is an independent general-purpose operating system with the redefined concept of Unix "Do one task and do it correctly" to "Use one file for one task". From one file I mean one file for the complete operating system to a simple user App. rlxos boots directly from the system image using overlay filesystem (just like the other GNU/Linux system do in LiveCD) and all the changes are done and stored in a separate directory, In this way users are always on the safe side from breaking the system.

![rlxos 2200 System Structure](../assets/concept_1.svg)

## Protected System Roots

The System roots filesystem is protected using the overlay filesystem, and all the changes made by the user are stored above the System Image layer in the User cache.

To get a better understanding of this, assume a drawing of a flower, and you have to color it.

You do is to directly start coloring on the drawing paper, but I put a tracing paper on it

![](../assets/concept_2.svg)

As you see in the above drawing if you did any mistake while coloring you need a new drawing but I just need to change the tracing paper to start again.

Now think of the flower drawing as the root filesystem of rlxos and tracing paper as the User cache layer and colorings like adding some packages or changing system configurations, if the user cache causes any issue then we can simply replace it.

To achieve this I uses the features of the overlay file system which work just is the same way, It is a layered filesystem one above the other, and in rlxos, the root filesystem is in the bottom layer and the user cache is the top one, so all the user changes are stored on the topmost layer

**Issues in the concept**

- As I say above if I did anything wrong I need to start from the starting again. (this issue can be overcome by using the backups of User caches at regular intervals

- A conceptual issue we have is when using the concept we have two copies of modified files the original one in the System image and the modified one in the user cache [This thing basically take a little extra space than usual]


## Atomic Updates and easily revert back

It's now easy for both of us to understand and implement the concept of atomic updates in rlxos. According to Google
> An atomic operation is one that changes a system from one state to another without visibly passing through any intermediate states.

So what I am doing in rlxos is just replacing the system image with other, simple right? but we have some minute issues in this too.

- Let's assume the example of the flower drawing again, as I correlate the drawing as System Roots layer and User caches as tracing paper, and if I did something wrong I replace the user cache. Now suppose we replace the drawing itself

![](../assets/concept_3.svg)

Yes, it sucks, and to fix this issue rlxos create Image Specific User Cache, and from this, I got the idea of our next feature.

## Multiple versions and builds can exist together

As you read above, you are already clear how I achieve this thing. So now the structure is something like this

![](../assets/concept_4.svg)

And the good news is we had only one issue in the concept which is already fixed by the rlxos  2200 build i.e. we previously during the 2107 build we have Linux kernel (inside /boot) on the bottom-most layer and its module in the system image layer (inside /usr/lib/modules). but now after the release of the rlxos 2200 build, we now moved both the kernel (in /boot) and modules (in /boot/modules) to the bottom layer.

## AppImages - Concept by probono

It's one of the coolest things I found on the Internet. This is a simple self-dependent packing format (a squashed filesystem) that mounts itself during execution and runs the application from that, (a little complicated concept behind) but as end-user, we just need to download them and execute them, simple right?. that's why I use this as primary packaging system in rlxos. Alternatively, we have PKGUPD (which I don't recommend unless mentioned in guides) through which end-user (developers one) can install packages that can't be distributed as AppImages like GCC, LLVM, or maybe kernel headers. To know about PackageManagement in rlxos please follow the Package Management part of the guide.

I have achieved a lot of what I think for rlxos and assume it to ready to rock and if you are ready for these exciting features (and a lot more) and random issues, lack of packages (overcome using flatpak and snaps). you can boot rlxos on your system. However, I still recommend using it as your secondary system (maybe as primary if you are a software developer).