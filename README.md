# Project goal

This project aims to package a Spring Boot application in a Docker image with minimal JRE dependencies.

To achieve this goal, we will take advantage of two tools provided by JDK:
- jdeps
- jlink

## jdeps

 jdeps is a command line which extracts class dependencies of Java class file.

## jlink
 jlink is command line which allows us to build a custom JRE.

## Objective
  We laverage jdeps to extract class dependencies of our Spring Boot appplication. Then, we build a custom JRE containing previously extracted class dependecies.

# Dockerfile

We use Multi-stage builds Dockerfile. Dockerfile is composed with two stages:
- Building the application and its custom JRE stage.
- Packaging the application.

We use  **Alpine Linux** as base image.

## Building the application and its custom JRE stage

In this stage, we execute the following steps:

1. Build the Spring Boot application as Jar file.
2. Unzip the Jar file.
3. Apply class dependecy analysis with **jdeps**.
4. Build a custom JRE.

## Packaging the application

Now, we are ready to build the image which will run the application.

- First, we define some envirement variables. 
- Then, we install **bash** and **jemalloc** library. 
- Finally, we copy the application and its custom JRE from the previous stage. 


# References

1. [jdeps](https://docs.oracle.com/javase/9/tools/jdeps.htm#JSWOR690)
2. [jlink](https://docs.oracle.com/javase/9/tools/jlink.htm#JSWOR-GUID-CECAC52B-CFEE-46CB-8166-F17A8E9280E9)
3. [[JAVA] Comment réduire l'image de Spring Boot Docker](https://linuxtut.com/fr/517132e01c844d426c09/) 
