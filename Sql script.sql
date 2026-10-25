-- ==========================================
-- HEALTHCONNECT RWANDA - PATIENT ANALYSIS ( 1 TO 10)
-- ==========================================

-- 1: Retrieve all registered patients
SELECT * 
FROM patients;


-- 2: Count patients by gender
SELECT gender, COUNT(*) AS total_patients
FROM patients
GROUP BY gender;


-- 3: Count patients by province
SELECT p.province_name, COUNT(pat.patient_id) AS total_patients
FROM patients pat
JOIN hc_villages v ON pat.village_id = v.village_id
JOIN hc_sectors s ON v.sector_id = s.sector_id
JOIN hc_districts d ON s.district_id = d.district_id
JOIN hc_provinces p ON d.province_id = p.province_id
GROUP BY p.province_name;


-- 4: Identify patients above 65 years
SELECT *
FROM patients
WHERE age > 65;


-- 5: Find patients with chronic diseases
SELECT *
FROM patients
WHERE chronic_condition IS NOT NULL AND chronic_condition != 'None';


-- 6: Retrieve patients covered by insurance
SELECT *
FROM patients
WHERE insurance_id IS NOT NULL;


-- 7: Count patients by blood group
SELECT blood_group, COUNT(*) AS total_patients
FROM patients
GROUP BY blood_group;


-- 8: List the youngest and oldest patients
(
    SELECT 'Youngest Patient' AS category, first_name, last_name, age 
    FROM patients 
    ORDER BY age ASC 
    LIMIT 1
)
UNION ALL
(
    SELECT 'Oldest Patient' AS category, first_name, last_name, age 
    FROM patients 
    ORDER BY age DESC 
    LIMIT 1
);


-- 9: Identify duplicate phone numbers
SELECT phone, COUNT(*) AS duplicate_count
FROM patients
WHERE phone IS NOT NULL
GROUP BY phone
HAVING COUNT(*) > 1;


-- 10: Calculate average patient age
SELECT ROUND(AVG(age), 2) AS average_patient_age
FROM patients;

-- ==========================================
-- HEALTHCONNECT RWANDA - APPOINTMENT ANALYSIS (11 TO 20)
-- ==========================================

-- 11: Count appointments by month
SELECT TO_CHAR(appointment_date, 'YYYY-MM') AS appointment_month, COUNT(*) AS total_appointments
FROM hc_appointments
GROUP BY TO_CHAR(appointment_date, 'YYYY-MM')
ORDER BY appointment_month;

-- 12: Identify busiest hospitals (facilities) by Facility ID
SELECT facility_id, COUNT(appointment_id) AS total_appointments
FROM hc_appointments
GROUP BY facility_id
ORDER BY total_appointments DESC;

-- 13: Find busiest departments
SELECT d.department_name, COUNT(a.appointment_id) AS total_appointments
FROM hc_appointments a
JOIN hc_departments d ON a.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_appointments DESC;


-- 14: Find doctors with the highest workload
SELECT doc.first_name, doc.last_name, COUNT(a.appointment_id) AS total_appointments
FROM hc_appointments a
JOIN hc_doctor doc ON a.doctor_id = doc.staff_id
GROUP BY doc.first_name, doc.last_name
ORDER BY total_appointments DESC;


-- 15: Identify referral patterns
SELECT visit_type, COUNT(*) AS total_visits
FROM hc_appointments
GROUP BY visit_type
ORDER BY total_visits DESC;


-- 16: Count emergency appointments
SELECT COUNT(*) AS emergency_appointments_count
FROM hc_appointments
WHERE LOWER(visit_type) LIKE '%emergency%';


-- 17: Calculate average appointments per doctor
SELECT ROUND(AVG(doctor_appointments), 2) AS avg_appointments_per_doctor
FROM (
    SELECT doctor_id, COUNT(*) AS doctor_appointments
    FROM hc_appointments
    WHERE doctor_id IS NOT NULL
    GROUP BY doctor_id
) sub;


-- 18: Retrieve appointments by province
SELECT p.province_name, COUNT(a.appointment_id) AS total_appointments
FROM hc_appointments a
JOIN hc_facility_master_departments f ON a.facility_id = f.facility_id
JOIN hc_districts d ON f.facility_id = d.district_id -- Adjust join path depending on your facility-province linkage
JOIN hc_provinces p ON d.province_id = p.province_id
GROUP BY p.province_name;


-- 19: Identify facilities with the highest patient volume (grouped by facility_id)
SELECT facility_id, COUNT(DISTINCT patient_id) AS unique_patients
FROM hc_appointments
GROUP BY facility_id
ORDER BY unique_patients DESC;

-- 20: Find peak consultation periods (by hour or time of day)
SELECT TO_CHAR(appointment_date, 'HH24:00') AS appointment_hour, COUNT(*) AS total_appointments
FROM hc_appointments
GROUP BY TO_CHAR(appointment_date, 'HH24:00')
ORDER BY total_appointments DESC;

-- ==========================================
-- HEALTHCONNECT RWANDA - CLINICAL ANALYSIS (21 TO 30)
-- ==========================================

-- 21: Top diagnoses
SELECT diagnosis, COUNT(*) AS total_cases
FROM hc_diagnoses
GROUP BY diagnosis
ORDER BY total_cases DESC
LIMIT 20;


-- 22: Most requested laboratory tests (using HC_Services filtered for lab services or matching appointments)
SELECT s.service_name, COUNT(a.appointment_id) AS request_count
FROM hc_appointments a
JOIN hc_services s ON a.department_id = s.department_id
WHERE LOWER(s.service_name) LIKE '%lab%' OR LOWER(s.service_name) LIKE '%test%'
GROUP BY s.service_name
ORDER BY request_count DESC;


-- 23: Most prescribed medications / pharmacy services
SELECT s.service_name, COUNT(a.appointment_id) AS prescription_count
FROM hc_appointments a
JOIN hc_services s ON a.department_id = s.department_id
WHERE LOWER(s.service_name) LIKE '%pharmacy%' 
   OR LOWER(s.service_name) LIKE '%medication%' 
   OR LOWER(s.service_name) LIKE '%prescription%'
   OR LOWER(s.service_name) LIKE '%drug%'
GROUP BY s.service_name
ORDER BY prescription_count DESC;


-- 24: Average admission duration / visit metrics (using visit types)
SELECT visit_type, COUNT(*) AS total_visits
FROM hc_appointments
GROUP BY visit_type;


-- 25: Disease severity distribution
SELECT severity, COUNT(*) AS total_cases
FROM hc_diagnoses
GROUP BY severity
ORDER BY total_cases DESC;


-- 26: Laboratory test utilization (using HC_Services for lab procedures)
SELECT s.service_name, COUNT(a.appointment_id) AS total_utilization
FROM hc_appointments a
JOIN hc_services s ON a.department_id = s.department_id
WHERE LOWER(s.service_name) LIKE '%lab%' 
   OR LOWER(s.service_name) LIKE '%test%'
GROUP BY s.service_name
ORDER BY total_utilization DESC;

-- 27: Prescription/Appointment trends by month
SELECT TO_CHAR(appointment_date, 'YYYY-MM') AS appointment_month, COUNT(*) AS total_appointments
FROM hc_appointments
GROUP BY TO_CHAR(appointment_date, 'YYYY-MM')
ORDER BY appointment_month;


-- 28: Referral destinations
SELECT visit_type, COUNT(*) AS total_referrals
FROM hc_appointments
WHERE LOWER(visit_type) LIKE '%referral%'
GROUP BY visit_type;


-- 29: Admission rate or diagnosis breakdown (using diagnoses severity)
SELECT severity, COUNT(*) AS total_cases
FROM hc_diagnoses
GROUP BY severity
ORDER BY total_cases DESC;


-- 30: Clinical workload by department
SELECT dep.department_name, COUNT(a.appointment_id) AS clinical_workload
FROM hc_appointments a
JOIN hc_departments dep ON a.department_id = dep.department_id
GROUP BY dep.department_name
ORDER BY clinical_workload DESC;


-- ==========================================
-- HEALTHCONNECT RWANDA - FINANCIAL ANALYSIS (31 TO 40)
-- ==========================================

-- 31: Revenue by facility
SELECT a.facility_id, SUM(b.amount) AS total_revenue
FROM hc_billing b
JOIN hc_appointments a ON b.appointment_id = a.appointment_id
WHERE b.status = 'Paid'
GROUP BY a.facility_id
ORDER BY total_revenue DESC;


-- 32: Revenue by department
SELECT a.department_id, SUM(b.amount) AS total_revenue
FROM hc_billing b
JOIN hc_appointments a ON b.appointment_id = a.appointment_id
WHERE b.status = 'Paid'
GROUP BY a.department_id
ORDER BY total_revenue DESC;


-- 33: Revenue by service (joining through departments and services)
SELECT s.service_name, SUM(b.amount) AS total_revenue
FROM hc_billing b
JOIN hc_appointments a ON b.appointment_id = a.appointment_id
JOIN hc_services s ON a.department_id = s.department_id
WHERE b.status = 'Paid'
GROUP BY s.service_name
ORDER BY total_revenue DESC;


-- 34: Insurance claims by provider
SELECT provider, COUNT(*) AS total_claims, SUM(claim_amount) AS total_claim_amount
FROM insurance_claims
GROUP BY provider
ORDER BY total_claim_amount DESC;


-- 35: Outstanding payments (Pending or Unpaid bills)
SELECT *
FROM hc_billing
WHERE LOWER(status) != 'paid';


-- 36: Average billing amount
SELECT ROUND(AVG(amount), 2) AS average_billing_amount
FROM hc_billing;


-- 37: Monthly revenue trend (using your revenue summary table)
SELECT month, revenue, appointments
FROM hc_revenue_summary
ORDER BY month;


-- 38: Payment methods breakdown
SELECT method, COUNT(*) AS transaction_count, SUM(amount_paid) AS total_amount_paid
FROM payments
GROUP BY method
ORDER BY total_amount_paid DESC;


-- 39: Top revenue-generating hospitals (facilities)
SELECT a.facility_id, SUM(b.amount) AS total_revenue
FROM hc_billing b
JOIN hc_appointments a ON b.appointment_id = a.appointment_id
WHERE b.status = 'Paid'
GROUP BY a.facility_id
ORDER BY total_revenue DESC
LIMIT 10;


-- 40: Financial performance ranking (ranked facilities by revenue)
SELECT a.facility_id, 
       SUM(b.amount) AS total_revenue,
       RANK() OVER (ORDER BY SUM(b.amount) DESC) AS revenue_rank
FROM hc_billing b
JOIN hc_appointments a ON b.appointment_id = a.appointment_id
WHERE b.status = 'Paid'
GROUP BY a.facility_id;
