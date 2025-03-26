// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Hello world");
    ?mqttReady.

/*
* Plan for looking up created MQTT artifact by personal assistant.
* If not ready yet, wait for 50ms and retry.
* According to: https://www.emse.fr/~boissier/enseignement/maop13/courses/cartagoByExamples.pdf (p.18)
*/
+?mqttReady : true <-
    lookupArtifact("mqttArtifact", MQTTArtifactId);
    focus(MQTTArtifactId).
-?mqttReady : true <-
    .wait(50);
    ?mqttReady.

/* Plan for reacting to received messages
 * Triggering event: addition of observable property message
 * Context: true (the plan is always applicable)
 * Body: prints the received message
*/
@react_to_message
+message(Sender, Performative, Content) : true <-
    .print("Received message from ", Sender, " with performative: ", Performative, " and content: ", Content).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }