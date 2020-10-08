ARG image=alpine/git
ARG release=latest

FROM $image:$release AS clone

ARG dir=clone-folder
ARG hostname=github.com
ARG project=spring-petclinic
ARG username=secobau

WORKDIR /$dir
RUN git clone https://$hostname/$username/$project

###

ARG image=maven
ARG release=alpine

FROM $image:$release AS build

ARG from_old=clone
ARG dir_old=clone-folder
ARG dir=build-folder
ARG project=spring-petclinic

WORKDIR /$dir
COPY --from=clone /$dir_old/$project . 
RUN mvn install && mv target/$project-*.jar target/$project.jar

###

ARG image=openjdk
ARG release=jre-alpine

FROM $image:$release AS production

ARG from_old=build
ARG dir_old=build-folder/target
ARG dir=production-folder
ARG project=spring-petclinic.jar

WORKDIR /$dir
COPY --from=build /$dir_old/$project . 
ENTRYPOINT ["java","-jar"]
#CMD ["$project"]
CMD $project
