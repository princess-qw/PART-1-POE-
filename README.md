# RaceDay Event Management System

## Project Description

RaceDay is an event management system designed to support the organisation and participation of running events.

The system allows organisers to create and manage events, event categories, sponsors, participant enrolments, payments, race results and weather information.

Participants can create accounts, view available events and categories, enrol in race categories, make payments and view their race results.

## User Roles

### Organiser

The Organiser is responsible for managing RaceDay events.

The Organiser can:

- Create, update and delete events
- Create and manage event categories
- View participant enrolments
- Manage payment statuses
- Record and update race results
- Create and manage sponsors
- Link sponsors to events
- Refresh and manage event weather information

### Participant

The Participant uses the system to take part in RaceDay events.

The Participant can:

- Register for an account
- View upcoming events
- View available event categories
- Enrol in a race category
- View and cancel their own enrolments
- Submit payments
- View their race result history

## Project Documentation

The `/docs` folder contains the main planning and database files for the project:

- `ERD.png` – Final Entity Relationship Diagram
- `ERD.drawio` – Editable ERD source file
- `RaceDay_API_Endpoint_Plan.md` – API endpoint plan
- `RaceDay_Database.sql` – SQL Server database script

## Database

The RaceDay database was created using Microsoft SQL Server Management Studio (SSMS).

The SQL script:

- Creates the RaceDay database
- Creates all required tables
- Defines primary keys and foreign keys
- Applies constraints such as NOT NULL, UNIQUE, CHECK and DEFAULT
- Inserts realistic sample data
- Includes verification queries to test the database relationships

## CI/CD

GitHub Actions is used to validate that the required project documentation exists in the `/docs` folder.

### Successful Build

A screenshot of the successful GitHub Actions workflow will be added here.

## Video Demonstration

An unlisted YouTube video will be added here after recording.

YouTube link:

`To be added`
