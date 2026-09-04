# RaceDay -- Section B: API Endpoint Plan

This API endpoint plan was prepared for the RaceDay event management
system. It is designed to cover the required functionality for
Authentication, User Profiles, Events, Categories, Event Enrolments and
Results, together with the additional functionality for Payments,
Sponsors and Weather.

## Role Legend

-   **None** -- Public endpoint; no login required.
-   **Any** -- Any authenticated/logged-in user.
-   **Participant** -- Participant role required.
-   **Organiser** -- Organiser role required.
-   **Organiser (owner)** -- The logged-in organiser must own the
    related event.

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  HTTP Method Route                                          Description     Role Required Request Body (if any)                                                                                     Expected Response
  ----------- ---------------------------------------------- --------------- ------------- --------------------------------------------------------------------------------------------------------- --------------------
  POST        `/api/auth/register`                           Creates a new   None (public) `{ email, password, role, firstName, lastName, phone, dateOfBirth }` -- `dateOfBirth` is used for         **201 Created** --
                                                             user account                  Participants.                                                                                             new user object
                                                             and a linked                                                                                                                            without password;
                                                             Organiser or                                                                                                                            **400 Bad Request**
                                                             Participant                                                                                                                             -- validation
                                                             profile                                                                                                                                 failed; **409
                                                             according to                                                                                                                            Conflict** -- email
                                                             the selected                                                                                                                            already registered.
                                                             role.                                                                                                                                   

  POST        `/api/auth/login`                              Authenticates a None (public) `{ email, password }`                                                                                     **200 OK** --
                                                             registered user                                                                                                                         `{ token, user }`;
                                                             and returns a                                                                                                                           **401 Unauthorized**
                                                             JWT for                                                                                                                                 -- invalid
                                                             authenticated                                                                                                                           credentials.
                                                             requests.                                                                                                                               

  GET         `/api/users/me`                                Returns the     Any           None                                                                                                      **200 OK** -- user
                                                             logged-in                                                                                                                               and profile object;
                                                             user's Users                                                                                                                            **401
                                                             record together                                                                                                                         Unauthorized**.
                                                             with the linked                                                                                                                         
                                                             Organiser or                                                                                                                            
                                                             Participant                                                                                                                             
                                                             profile.                                                                                                                                

  PUT         `/api/users/me`                                Updates the     Any           `{ firstName, lastName, phone, dateOfBirth }`                                                             **200 OK** --
                                                             logged-in                                                                                                                               updated profile;
                                                             user's own                                                                                                                              **400 Bad Request**.
                                                             profile                                                                                                                                 
                                                             information.                                                                                                                            

  PUT         `/api/users/me/password`                       Changes the     Any           `{ currentPassword, newPassword }`                                                                        **200 OK** --
                                                             logged-in                                                                                                                               confirmation
                                                             user's password                                                                                                                         message; **401
                                                             after checking                                                                                                                          Unauthorized** --
                                                             the current                                                                                                                             current password
                                                             password.                                                                                                                               incorrect.

  GET         `/api/events`                                  Lists upcoming  None (public) None                                                                                                      **200 OK** -- array
                                                             RaceDay events.                                                                                                                         of event objects.
                                                             Optional                                                                                                                                
                                                             filtering can                                                                                                                           
                                                             be applied by                                                                                                                           
                                                             province, event                                                                                                                         
                                                             type or date.                                                                                                                           

  GET         `/api/events/{id}`                             Returns full    None (public) None                                                                                                      **200 OK** -- event
                                                             details for one                                                                                                                         object with
                                                             event,                                                                                                                                  categories; **404
                                                             including its                                                                                                                           Not Found**.
                                                             categories.                                                                                                                             

  POST        `/api/events`                                  Creates a new   Organiser     `{ eventName, eventType, eventDate, city, province, venue, description }`                                 **201 Created** --
                                                             event owned by                                                                                                                          new event object;
                                                             the logged-in                                                                                                                           **400 Bad Request**.
                                                             organiser.                                                                                                                              

  PUT         `/api/events/{id}`                             Updates an      Organiser     `{ eventName, eventType, eventDate, city, province, venue, description }`                                 **200 OK** --
                                                             event owned by  (owner)                                                                                                                 updated event; **403
                                                             the logged-in                                                                                                                           Forbidden**; **404
                                                             organiser.                                                                                                                              Not Found**.

  DELETE      `/api/events/{id}`                             Deletes an      Organiser     None                                                                                                      **200 OK** --
                                                             event and its   (owner)                                                                                                                 confirmation
                                                             related                                                                                                                                 message; **403
                                                             categories.                                                                                                                             Forbidden**; **404
                                                                                                                                                                                                     Not Found**.

  GET         `/api/events/{eventId}/categories`             Lists all       None (public) None                                                                                                      **200 OK** -- array
                                                             categories                                                                                                                              of category objects;
                                                             available for a                                                                                                                         **404 Not Found**.
                                                             specific event,                                                                                                                         
                                                             such as 5 km or                                                                                                                         
                                                             10 km.                                                                                                                                  

  GET         `/api/categories/{id}`                         Returns full    None (public) None                                                                                                      **200 OK** --
                                                             information for                                                                                                                         category object;
                                                             one category,                                                                                                                           **404 Not Found**.
                                                             including route                                                                                                                         
                                                             information                                                                                                                             
                                                             such as start                                                                                                                           
                                                             point, end                                                                                                                              
                                                             point,                                                                                                                                  
                                                             elevation and                                                                                                                           
                                                             map URL.                                                                                                                                

  POST        `/api/events/{eventId}/categories`             Adds a new      Organiser     `{ categoryName, distanceKm, entryFee, maxParticipants, startPoint, endPoint, elevationGainM, mapURL }`   **201 Created** --
                                                             category and    (owner)                                                                                                                 new category object;
                                                             its route                                                                                                                               **403 Forbidden**;
                                                             information to                                                                                                                          **404 Not Found**.
                                                             an event.                                                                                                                               

  PUT         `/api/categories/{id}`                         Updates a       Organiser     `{ categoryName, distanceKm, entryFee, maxParticipants, startPoint, endPoint, elevationGainM, mapURL }`   **200 OK** --
                                                             category's      (owner)                                                                                                                 updated category;
                                                             details and                                                                                                                             **403 Forbidden**;
                                                             route                                                                                                                                   **404 Not Found**.
                                                             information.                                                                                                                            

  DELETE      `/api/categories/{id}`                         Deletes a       Organiser     None                                                                                                      **200 OK** --
                                                             category when   (owner)                                                                                                                 confirmation
                                                             it has no                                                                                                                               message; **403
                                                             active                                                                                                                                  Forbidden**; **409
                                                             enrolments.                                                                                                                             Conflict** -- active
                                                                                                                                                                                                     enrolments exist.

  POST        `/api/categories/{categoryId}/enrolments`      Enrols the      Participant   `{ }` -- participant is obtained from the logged-in JWT.                                                  **201 Created** --
                                                             logged-in                                                                                                                               enrolment with bib
                                                             participant in                                                                                                                          number; **404 Not
                                                             a category,                                                                                                                             Found**; **409
                                                             assigns a bib                                                                                                                           Conflict** --
                                                             number and                                                                                                                              already enrolled or
                                                             creates a                                                                                                                               category is full.
                                                             Pending payment                                                                                                                         
                                                             record.                                                                                                                                 

  GET         `/api/users/me/enrolments`                     Returns all     Participant   None                                                                                                      **200 OK** -- array
                                                             past and                                                                                                                                of enrolment
                                                             upcoming                                                                                                                                objects.
                                                             enrolments                                                                                                                              
                                                             belonging to                                                                                                                            
                                                             the logged-in                                                                                                                           
                                                             participant.                                                                                                                            

  GET         `/api/categories/{categoryId}/enrolments`      Returns all     Organiser     None                                                                                                      **200 OK** -- array
                                                             participants    (owner)                                                                                                                 of enrolments; **403
                                                             enrolled in a                                                                                                                           Forbidden**.
                                                             category.                                                                                                                               

  DELETE      `/api/enrolments/{id}`                         Cancels an      Participant   None                                                                                                      **200 OK** --
                                                             enrolment       (own) or                                                                                                                confirmation
                                                             belonging to    Organiser                                                                                                               message; **403
                                                             the participant (owner)                                                                                                                 Forbidden**; **404
                                                             or managed by                                                                                                                           Not Found**.
                                                             the event                                                                                                                               
                                                             owner.                                                                                                                                  

  GET         `/api/enrolments/{enrolmentId}/payment`        Returns the     Participant   None                                                                                                      **200 OK** --
                                                             payment record  (own) or                                                                                                                payment object;
                                                             linked to an    Organiser                                                                                                               **403 Forbidden**;
                                                             enrolment.      (owner)                                                                                                                 **404 Not Found**.

  POST        `/api/enrolments/{enrolmentId}/payment`        Submits payment Participant   `{ amount, paymentMethod, transactionRef }`                                                               **201 Created** --
                                                             for the         (own)                                                                                                                   payment object with
                                                             enrolment entry                                                                                                                         Paid status; **404
                                                             fee.                                                                                                                                    Not Found**; **409
                                                                                                                                                                                                     Conflict** --
                                                                                                                                                                                                     already paid.

  PUT         `/api/payments/{id}`                           Updates a       Organiser     `{ paymentStatus }`                                                                                       **200 OK** --
                                                             payment status, (owner)                                                                                                                 updated payment;
                                                             for example                                                                                                                             **403 Forbidden**;
                                                             when processing                                                                                                                         **404 Not Found**.
                                                             a refund.                                                                                                                               

  POST        `/api/enrolments/{enrolmentId}/result`         Records a       Organiser     `{ finishTime, position, status }`                                                                        **201 Created** --
                                                             participant's   (owner)                                                                                                                 result object; **403
                                                             result,                                                                                                                                 Forbidden**; **404
                                                             including                                                                                                                               Not Found**; **409
                                                             finish time,                                                                                                                            Conflict** -- result
                                                             finishing                                                                                                                               already exists.
                                                             position and                                                                                                                            
                                                             result status.                                                                                                                          

  PUT         `/api/results/{id}`                            Corrects or     Organiser     `{ finishTime, position, status }`                                                                        **200 OK** --
                                                             updates a       (owner)                                                                                                                 updated result;
                                                             previously                                                                                                                              **403 Forbidden**;
                                                             captured                                                                                                                                **404 Not Found**.
                                                             result.                                                                                                                                 

  GET         `/api/users/me/results`                        Returns the     Participant   None                                                                                                      **200 OK** -- array
                                                             logged-in                                                                                                                               of result objects.
                                                             participant's                                                                                                                           
                                                             complete result                                                                                                                         
                                                             history across                                                                                                                          
                                                             events.                                                                                                                                 

  GET         `/api/categories/{categoryId}/results`         Returns the     None (public) None                                                                                                      **200 OK** -- array
                                                             public                                                                                                                                  of result objects
                                                             leaderboard for                                                                                                                         ordered by position.
                                                             a category,                                                                                                                             
                                                             ordered by                                                                                                                              
                                                             finishing                                                                                                                               
                                                             position.                                                                                                                               

  GET         `/api/sponsors`                                Lists all       None (public) None                                                                                                      **200 OK** -- array
                                                             sponsors                                                                                                                                of sponsor objects.
                                                             available on                                                                                                                            
                                                             the RaceDay                                                                                                                             
                                                             platform.                                                                                                                               

  POST        `/api/sponsors`                                Creates a new   Organiser     `{ sponsorName, contactEmail, contactPhone, logoURL }`                                                    **201 Created** --
                                                             sponsor record.                                                                                                                         sponsor object;
                                                                                                                                                                                                     **400 Bad Request**.

  PUT         `/api/sponsors/{id}`                           Updates sponsor Organiser     `{ sponsorName, contactEmail, contactPhone, logoURL }`                                                    **200 OK** --
                                                             information.                                                                                                                            updated sponsor;
                                                                                                                                                                                                     **404 Not Found**.

  GET         `/api/events/{eventId}/sponsors`               Lists sponsors  None (public) None                                                                                                      **200 OK** -- array
                                                             linked to a                                                                                                                             of sponsors with
                                                             specific event,                                                                                                                         tier.
                                                             including                                                                                                                               
                                                             sponsorship                                                                                                                             
                                                             tier.                                                                                                                                   

  POST        `/api/events/{eventId}/sponsors`               Links a sponsor Organiser     `{ sponsorId, sponsorshipTier }`                                                                          **201 Created** --
                                                             to an event     (owner)                                                                                                                 event-sponsor link;
                                                             with a                                                                                                                                  **403 Forbidden**;
                                                             sponsorship                                                                                                                             **409 Conflict** --
                                                             tier.                                                                                                                                   sponsor already
                                                                                                                                                                                                     linked.

  DELETE      `/api/events/{eventId}/sponsors/{sponsorId}`   Removes a       Organiser     None                                                                                                      **200 OK** --
                                                             sponsor from an (owner)                                                                                                                 confirmation
                                                             event.                                                                                                                                  message; **403
                                                                                                                                                                                                     Forbidden**; **404
                                                                                                                                                                                                     Not Found**.

  GET         `/api/events/{eventId}/weather`                Returns the     None (public) None                                                                                                      **200 OK** -- latest
                                                             latest weather                                                                                                                          WeatherLog object;
                                                             snapshot stored                                                                                                                         **404 Not Found** --
                                                             for an event.                                                                                                                           no weather has been
                                                                                                                                                                                                     logged.

  GET         `/api/events/{eventId}/weather/history`        Returns all     None (public) None                                                                                                      **200 OK** -- array
                                                             weather                                                                                                                                 of WeatherLog
                                                             snapshots                                                                                                                               objects.
                                                             recorded for an                                                                                                                         
                                                             event over                                                                                                                              
                                                             time.                                                                                                                                   

  POST        `/api/events/{eventId}/weather/refresh`        Requests        Organiser     None                                                                                                      **201 Created** --
                                                             current weather (owner)                                                                                                                 new WeatherLog
                                                             from the                                                                                                                                object; **404 Not
                                                             external                                                                                                                                Found** -- event
                                                             weather service                                                                                                                         does not exist;
                                                             for the event                                                                                                                           **502 Bad Gateway**
                                                             location/date                                                                                                                           -- external weather
                                                             and stores a                                                                                                                            service unavailable.
                                                             new WeatherLog                                                                                                                          
                                                             entry.                                                                                                                                  
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Endpoint Coverage

The plan covers the minimum areas required by the assignment:

-   **Authentication:** register and login
-   **User Profile:** view profile, update profile and change password
-   **Events:** create, view, update, delete and filter events
-   **Categories:** create, view, update and delete event categories
-   **Event Enrolments:** enrol, view and cancel enrolments
-   **Results:** capture, update, view personal history and public
    leaderboards

Additional planned functionality includes:

-   **Payments**
-   **Sponsors**
-   **Weather**

The API implemented in Part 2 should follow this plan closely. Any
intentional change to a route, request body, role or response should be
documented in the project's README.
