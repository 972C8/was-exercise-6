// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

// the agent initially believes that there are no upcoming events
upcoming_event(_).

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
// Task 2
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    makeArtifact("calendarService", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_upcoming_event.

@read_upcoming_event_plan
+!read_upcoming_event : true <-
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventList);
    .nth(0, UpcomingEventList, UpcomingEvent);
    -+upcoming_event(UpcomingEvent);
    .wait(5000);
    !read_upcoming_event.

// Task 3
/*
* Plan for reacting to the addition of an upcoming event
* Triggering event: addition of observable property upcoming_event
* Context: true (the plan is always applicable)
* Body: prints the upcoming event and sends message to personal assistant
*/
@upcoming_event_plan
+upcoming_event(UpcomingEvent) : true <-
    .print("Upcoming event: ", UpcomingEvent);
    .send(personal_assistant, tell, upcoming_event(UpcomingEvent)).

/*
* Refuse the goal to increase illuminance as it cannot do it
*/
@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    .send(Sender, tell, refuse(increase_illuminance)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
