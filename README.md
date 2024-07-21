# Examples with Obscure Uses of Maven Properties

See Stack Overflow question:
[Can `${...}` properties appear in the `<parent>` section of a POM file?](https://stackoverflow.com/questions/78752180/can-properties-appear-in-the-parent-section-of-a-pom-file)

While Maven's documentation claims that property values
["are accessible anywhere within a POM"](https://maven.apache.org/pom.html#Properties),
there are several tags that must be "constant", i.e. you _cannot_ use
property values in them.  Today (2024/7/21) those restrictions are
_undocumented_ and
_unenforced_.

Some restrictions can be discovered by trial-and-error, provided you pay
attention to Maven's warnings.

To complicate matters, some properties _are_ allowed in tags that are supposed
to be constant.  For instance,
[magic CI-friendly version properties](https://maven.apache.org/maven-ci-friendly.html)
can appear in `<version>` and `<parent> -> <version>`.  There may be other
exceptions as well; I can't find a definitive list of magic properties that
Maven treats differently.

## What's Here?

 - `baseline`: bog-standard parent-child project setup
 - `name-contains-property`: POM where name depends on a property defined in the same file
 - `groupid-contains-property`: POM where groupId depends on a property defined in the same file
 - `groupid-contains-property-defined-in-parent`: child's groupId depends on a property defined in the parent
 - `parent-groupid-contains-property-asymmetric`: child declares parent's groupId using a property; parent has a constant groupId
 - `parent-groupid-contains-property-symmetric`: child declares parent's groupId using a property; parent declares its own groupId the same way
 - `parent-version-contains-property-symmetric`: child declares parent's version using a property; parent declares its own version the same way
 - `parent-version-contains-revision-property-asymmetric`: child declares parent's groupId using the magic `${revision}` property; parent has a constant groupId
 - `parent-version-contains-revision-property-symmetric`: child declares parent's groupId using the magic `${revision}` property; parent declares its own groupId the same way

## Observations (Maven 3.9.7, JDK 17)

Maven expects these tags to be constant:

 - `<parent>` and everything in it
 - `<groupId>`, `<artifactId>`, and `<version>`
 - maybe others (see Open Questions below)

A few notes about specific examples I think are interesting:

_`groupid-contains-property` unexpectedly works._ Maven issues a warning, but
the effective POM has a groupId with the expanded property.

_`groupid-contains-property-defined-in-parent` unexpectedly works._ Maven
issues a warning, but the effective POM has a groupId with the expanded
property.

_`parent-groupid-contains-property-asymmetric` fails._  This is presumably
expected, but it might be surprising because the child _does_ contain enough
information to fully resolve the parent's groupId.

_`parent-groupid-contains-property-symmetric` unexpectedly works._  When the
groupIds are char-for-char equal before property expansion, Maven seems to
accept it (with a warning).  Note that this can produce a broken set of
effective POMs if the parent and child do not agree on the value of the
property.

_`parent-version-contains-revision-property-symmetric` works but produces
broken effective POMs._  **Maven issues no warnings in this case**, but the
final child POM references parent with version `v2.0` while the final parent
POM has version `v1.0`.

## Open Questions

 - Can properties appear in `<repositories>`? (A repo might be needed to find
   the parent, and the parent might have the value for the property.)
