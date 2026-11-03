# Coworking Space Booking Database

## Project Overview

This database was designed to manage bookings in a coworking space. Members can book desks, meeting rooms, or private offices for a specified number of hours, and payments associated with each booking are recorded.

## Database Tables

| Table | Description |
|---|---|
| `Members` | Stores member information, including name, email, membership type, and registration date. |
| `Workspaces` | Stores workspace information, including name, workspace type, capacity, and hourly rate. |
| `Bookings` | Stores booking details, including member, workspace, date, start time, duration, and booking status. |
| `Payments` | Stores payments made for bookings. |

## Relationships

- Each member can have multiple bookings.
- Each booking is associated with one specific workspace.
- Each payment is linked to a booking.

## Implementation Details

- Membership types, workspace types, booking statuses, and payment methods are restricted using `CHECK` constraints.
- Workspace capacity and hourly rates are validated to prevent invalid values.
- Member email addresses are unique.
- Booking amounts are calculated by multiplying the booking duration by the workspace's hourly rate.

## Sample Queries

The project includes the following SQL operations and queries:

- CRUD operations to insert, retrieve, update, and delete sample member records.
- Retrieve bookings along with the corresponding member and workspace names.
- Calculate the number of bookings and total booked hours grouped by workspace type.
- Calculate revenue grouped by membership type.
- Calculate the average booking duration for each workspace.
- Use the `HAVING` clause to identify members who have at least one booking.

## How to Run

Open the `CoworkingSpaceBookingDB.sql` file in SQL Server Management Studio (SSMS) and execute it.

After execution, the database, tables, sample data, and reporting queries will be created and ready to use.
