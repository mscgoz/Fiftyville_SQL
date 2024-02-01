-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Table 1: Airports            (id, abbreviation, full_name, city)
-- Table 2: atm_transactions    (id, account_number, year, month, day, atm_location, transaction_type, amount)
-- Table 3: bakery_security_logs(id, year, month, day, hour, minute, activity, license_plate)
-- Table 4: bank_accounts       (account_number, person_id[people.id], creation_year)
-- Table 5: crime_scene_reports (id, year,month, day, street, description)
-- Table 6: flights             (id, origin_airport_id[airports.id], destination_airport_id[airports.id], year, month, day, hour, minute)
-- Table 7: interviews          (id, name, year, month, day, transcript)
-- Table 8: passengers          (flight_id[flight.id], passport_number, seat)
-- Table 9: people              (id, name, phone_number, passport_number, license_plate)
-- Table 10: phone_calls        (id, caller, receiver, year, month, day, duration)

SELECT * FROM crime_scene_reports WHERE description LIKE '%CS50%'; -- To find out CS50 crime report: 28.07.2021 at 10:15 at Humphrey St., 3 witnesses were present, mentioned:bakery
SELECT * FROM interviews WHERE transcript LIKE '%bakery%'; --Ruth: within 10 m. of theft drove away(use security footage for licenseplate),
                                                           --Eugene: thieves were withdrawing money, early in morning(28.07) on Leggett St. ATM
                                                           --Raymond: as thief leaving bakery, someone called for 1 m. to take earliest flight tomorrow (29.07), told him to buy ticket

SELECT license_plate FROM bakery_security_logs WHERE hour = '10' AND minute BETWEEN '15' AND '25' AND day = '28' ORDER BY minute ASC; --Ruth:potential license plates:
                                                                    --+---------------+
                                                                    --| license_plate |
                                                                    --+---------------+
                                                                    --| 5P2BI95       |
                                                                    --| 94KL13X       |
                                                                    --| 6P58WS2       |
                                                                    --| 4328GD8       |
                                                                    --| G412CB7       |
                                                                    --| L93JTIZ       |
                                                                    --| 322W7JE       |
                                                                    --| 0NTHK55       |
                                                                    --+---------------+
SELECT * FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE hour = '10' AND minute BETWEEN '15' AND '25' AND day = '28' ORDER BY minute ASC);
--I checked the license plate in people table and found out:
                                        --+--------+---------+----------------+-----------------+---------------+
                                        --|   id   |  name   |  phone_number  | passport_number | license_plate |
                                        --+--------+---------+----------------+-----------------+---------------+
                                        --| 221103 | Vanessa | (725) 555-4692 | 2963008352      | 5P2BI95       |
                                        --| 243696 | Barry   | (301) 555-4174 | 7526138472      | 6P58WS2       |
                                        --| 396669 | Iman    | (829) 555-5269 | 7049073643      | L93JTIZ       |
                                        --| 398010 | Sofia   | (130) 555-0289 | 1695452385      | G412CB7       |
                                        --| 467400 | Luca    | (389) 555-5198 | 8496433585      | 4328GD8       |
                                        --| 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
                                        --| 560886 | Kelsey  | (499) 555-9472 | 8294398571      | 0NTHK55       |
                                        --| 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
                                        --+--------+---------+----------------+-----------------+---------------+

SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'; --Eugene: Withdraw transaction account number

                                                                --+----------------+
                                                                --| account_number |
                                                                --+----------------+
                                                                --| 28500762       |
                                                                --| 28296815       |
                                                                --| 76054385       |
                                                                --| 49610011       |
                                                                --| 16153065       |
                                                                --| 25506511       |
                                                                --| 81061156       |
                                                                --| 26013199       |
                                                                --+----------------+
--Let me find out if there I can match this list to person_id
-- first let me join atm_transactions with bank_accounts
-- then see if the acount number wihin this joined table correlates with the account number I found before
-- lastly, let me see the person ids of this matched account numbers

-- I FOUND: matching person_id's with the above account numbers in
SELECT DISTINCT(atm_transactions.account_number),bank_accounts.person_id FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw');
                                                            --+----------------+-----------+
                                                            --| account_number | person_id |
                                                            --+----------------+-----------+
                                                            --| 28500762       | 467400    |
                                                            --| 81061156       | 438727    |
                                                            --| 26013199       | 514354    |
                                                            --| 25506511       | 396669    |
                                                            --| 49610011       | 686048    |
                                                            --| 28296815       | 395717    |
                                                            --| 76054385       | 449774    |
                                                            --| 16153065       | 458378    |
                                                            --+----------------+-----------+
-- To have only the person id:
SELECT DISTINCT(bank_accounts.person_id) FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw');

                                                                        --+-----------+
                                                                        --| person_id |
                                                                        --+-----------+
                                                                        --| 467400    |
                                                                        --| 438727    |
                                                                        --| 514354    |
                                                                        --| 396669    |
                                                                        --| 686048    |
                                                                        --| 395717    |
                                                                        --| 449774    |
                                                                        --| 458378    |
                                                                        --+-----------+
--after findig person ids, i will match them with the license plate
-- then the person ids will be narrower

--with the narrowed person id, i will check with the phone calls

SELECT caller, receiver, duration FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration;

                                                        --+----------------+----------------+----------+
                                                        --|     caller     |    receiver    | duration |
                                                        --+----------------+----------------+----------+
                                                        --| (286) 555-6063 | (676) 555-6554 | 43       |
                                                        --| (367) 555-5533 | (375) 555-8161 | 45       |
                                                        --| (770) 555-1861 | (725) 555-3243 | 49       |
                                                        --| (499) 555-9472 | (717) 555-1342 | 50       |
                                                        --| (130) 555-0289 | (996) 555-8899 | 51       |
                                                        --| (338) 555-6650 | (704) 555-2131 | 54       |
                                                        --| (826) 555-1652 | (066) 555-9701 | 55       |
                                                        --| (609) 555-5876 | (389) 555-5198 | 60       |
                                                        --| (751) 555-6567 | (594) 555-6254 | 61       |
                                                        --| (669) 555-6918 | (971) 555-6468 | 67       |
                                                        --| (636) 555-4198 | (670) 555-8598 | 69       |
                                                        --| (367) 555-5533 | (704) 555-5790 | 75       |
                                                        --+----------------+----------------+----------+

-- These are only the callers
SELECT caller FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration;

                                                        --+--------------
                                                        --|     caller     |
                                                        --+----------------+
                                                        --| (286) 555-6063 |
                                                        --| (367) 555-5533 |
                                                        --| (770) 555-1861 |
                                                        --| (499) 555-9472 |
                                                        --| (130) 555-0289 |
                                                        --| (338) 555-6650 |
                                                        --| (826) 555-1652 |
                                                        --| (609) 555-5876 |
                                                        --| (751) 555-6567 |
                                                        --| (669) 555-6918 |
                                                        --| (636) 555-4198 |
                                                        --| (367) 555-5533 |
                                                        --+---------------
--These are the callers IDs from people table

SELECT * FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration);

                                                        --|   id   |  name   |  phone_number  | passport_number | license_plate |
                                                        --+--------+---------+----------------+-----------------+---------------+
                                                        --| 395717 | Kenny   | (826) 555-1652 | 9878712108      | 30G67EN       |
                                                        --| 398010 | Sofia   | (130) 555-0289 | 1695452385      | G412CB7       |
                                                        --| 438727 | Benista | (338) 555-6650 | 9586786673      | 8X428L0       |
                                                        --| 449774 | Taylor  | (286) 555-6063 | 1988161715      | 1106N58       |
                                                        --| 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
                                                        --| 560886 | Kelsey  | (499) 555-9472 | 8294398571      | 0NTHK55       |
                                                        --| 561160 | Kathryn | (609) 555-5876 | 6121106406      | 4ZY7I8T       |
                                                        --| 620297 | Peter   | (751) 555-6567 | 9224308981      | N507616       |
                                                        --| 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
                                                        --| 718152 | Jason   | (636) 555-4198 | 2818150870      | 8666X39       |
                                                        --| 779942 | Harold  | (669) 555-6918 |                 | DVS39US       |
                                                        --+--------+---------+----------------+-----------------+---------------+
-- These are only the reciver
SELECT receiver FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration;

                                                                                --+----------------+
                                                                                --|    receiver    |
                                                                                --+----------------+
                                                                                --| (676) 555-6554 |
                                                                                --| (375) 555-8161 |
                                                                                --| (725) 555-3243 |
                                                                                --| (717) 555-1342 |
                                                                                --| (996) 555-8899 |
                                                                                --| (704) 555-2131 |
                                                                                --| (066) 555-9701 |
                                                                                --| (389) 555-5198 |
                                                                                --| (594) 555-6254 |
                                                                                --| (971) 555-6468 |
                                                                                --| (670) 555-8598 |
                                                                                --| (704) 555-5790 |
                                                                                --+----------------+

--These are the callers IDs from people table
                                                        --+--------+---------+----------------+-----------------+---------------+
                                                        --|   id   |  name   |  phone_number  | passport_number | license_plate |
                                                        --+--------+---------+----------------+-----------------+---------------+
                                                        --| 250277 | James   | (676) 555-6554 | 2438825627      | Q13SVG6       |
                                                        --| 467400 | Luca    | (389) 555-5198 | 8496433585      | 4328GD8       |
                                                        --| 484375 | Anna    | (704) 555-2131 |                 |               |
                                                        --| 567218 | Jack    | (996) 555-8899 | 9029462229      | 52R0Y8U       |
                                                        --| 626361 | Melissa | (717) 555-1342 | 7834357192      |               |
                                                        --| 652398 | Carl    | (704) 555-5790 | 7771405611      | 81MZ921       |
                                                        --| 682850 | Ethan   | (594) 555-6254 | 2996517496      | NAW9653       |
                                                        --| 750165 | Daniel  | (971) 555-6468 | 7597790505      | FLFN3W0       |
                                                        --| 847116 | Philip  | (725) 555-3243 | 3391710505      | GW362R6       |
                                                        --| 864400 | Robin   | (375) 555-8161 |                 | 4V16VO0       |
                                                        --| 953420 | Amy     | (670) 555-8598 | 9355133130      |               |
                                                        --| 953679 | Doris   | (066) 555-9701 | 7214083635      | M51FA04       |
                                                        --+--------+---------+----------------+-----------------+---------------+


-- Let me check the bank accounts person id with the people id

SELECT * FROM people WHERE (license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE hour = '10' AND minute BETWEEN '15' AND '25' AND day = '28' ORDER BY minute ASC) AND id IN (SELECT DISTINCT(bank_accounts.person_id) FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')));


                                -- +--------+-------+----------------+-----------------+---------------+
                                -- |   id   | name  |  phone_number  | passport_number | license_plate |
                                -- +--------+-------+----------------+-----------------+---------------+
                                -- | 396669 | Iman  | (829) 555-5269 | 7049073643      | L93JTIZ       |
                                -- | 467400 | Luca  | (389) 555-5198 | 8496433585      | 4328GD8       |
                                -- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
                                -- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |

                                -- +--------+-------+----------------+-----------------+---------------+

SELECT * FROM people WHERE (phone_number IN (SELECT caller FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration) AND license_plate IN (SELECT license_plate FROM people WHERE (license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE hour = '10' AND minute BETWEEN '15' AND '25' AND day = '28' ORDER BY minute ASC) AND id IN (SELECT DISTINCT(bank_accounts.person_id) FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')))));
                                    -- +--------+-------+----------------+-----------------+---------------+
                                    -- |   id   | name  |  phone_number  | passport_number | license_plate |
                                    -- +--------+-------+----------------+-----------------+---------------+
                                    -- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
                                    -- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
                                    -- +--------+-------+----------------+-----------------+---------------+

--okay so, either Bruce or Diana is the thief, let me check the flights now if any of these names were in the flight

--So there were 2 flights in the morning

                        --+-----+-------------------+------------------------+------+-------+-----+------+--------+
                        --| id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
                        --+----+-------------------+------------------------+------+-------+-----+------+--------+
                        --| 36 | 8                 | 4                      | 2021 | 7     | 29  | 8    | 20     |
                        --| 43 | 8                 | 1                      | 2021 | 7     | 29  | 9    | 30     |
                        --+----+-------------------+------------------------+------+-------+-----+------+--------+

-- let me check if diana or bruce was on flight 36 or 43

SELECT passport_number FROM people WHERE (phone_number IN (SELECT caller FROM phone_calls WHERE day = '28' AND duration BETWEEN '40' AND '75' ORDER BY duration) AND license_plate IN (SELECT license_plate FROM people WHERE (license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE hour = '10' AND minute BETWEEN '15' AND '25' AND day = '28' ORDER BY minute ASC) AND id IN (SELECT DISTINCT(bank_accounts.person_id) FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE day = '28' AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')))));


-- +-----------+-----------------+------+
-- | flight_id | passport_number | seat |
-- +-----------+-----------------+------+
-- | 36        | 5773159633      | 4A   |
-- +-----------+-----------------+------+

--This passport number belong to:Bruce who is the thief, and he went to destination_airport 4

 SELECT * FROM airports WHERE id = '4';
--+----+--------------+-------------------+---------------+
--| id | abbreviation |     full_name     |     city      |
--+----+--------------+-------------------+---------------+
--| 4  | LGA          | LaGuardia Airport | New York City |
--+----+--------------+-------------------+---------------+

-- so he went to NYC

-- to find accomplice let me find who bruce talked on the phone for less than a min.

SELECT * FROM phone_calls WHERE caller = '(367) 555-5533' AND day = '28' AND duration < '60';
--+-----+----------------+----------------+------+-------+-----+----------+
--| id  |     caller     |    receiver    | year | month | day | duration |
--+-----+----------------+----------------+------+-------+-----+----------+
--| 233 | (367) 555-5533 | (375) 555-8161 | 2021 | 7     | 28  | 45       |
--+-----+----------------+----------------+------+-------+-----+----------+

-- Now let me find who this number belong to
SELECT * FROM people WHERE phone_number = '(375) 555-8161';

--That is Robin