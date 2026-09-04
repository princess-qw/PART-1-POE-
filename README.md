# RaceDay Event Management System

## System Description

RaceDay is an event management system designed to support the organisation and participation of running events.

The system allows organisers to create and manage events, race categories, sponsors, participant enrolments, payments, race results and weather information.

Participants can create accounts, view available events and categories, enrol in race categories, make payments and view their race results.

## User Roles

### Organiser

The Organiser is responsible for managing running events within the RaceDay system.

An Organiser can:
- Create, view, update and delete their events.
- Create and manage event categories.
- View participant enrolments for their events.
- Manage payment statuses.
- Create and update race results.
- Create sponsors and link sponsors to events.
- Access and refresh event weather information.

### Participant

The Participant is a user who registers for and participates in running events.

A Participant can:
- Register and manage their profile.
- View available events and race categories.
- Enrol in a race category.
- View and cancel their own enrolments.
- Submit payment information.
- View their race results.

## Project Documentation

The `/docs` folder contains the planning and database documentation for the RaceDay system, including:

- `ERD.png` – Entity Relationship Diagram.
- `RaceDay_API_Endpoint_Plan.md` – REST API endpoint plan.
- `RaceDay_Database.sql` – SQL Server database creation, sample data and verification script.

## CI/CD

GitHub Actions is used to validate the repository structure and confirm that the required RaceDay documentation files are present.

### Successful CI/CD Build

![Successful GitHub Actions Build](images/cicd-success.png)

## Video Demonstration

The following unlisted YouTube video demonstrates Sections A, B and C of the RaceDay Event Management System POE.

[Watch the RaceDay POE Demonstration on YouTube](https://youtube.com/watch?v=JFZP0ZBU8W0&si=E18L3oZsENgOZjQI)
