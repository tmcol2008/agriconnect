-- Uganda Land Management System Database
-- Based on the research document about land tenure and grabbing in Uganda

CREATE DATABASE uganda_land_management;
USE uganda_land_management;

-- =============================================
-- USER MANAGEMENT TABLES
-- =============================================

-- Users table for authentication and basic info
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    national_id VARCHAR(20) UNIQUE,
    user_type ENUM('citizen', 'government_official', 'legal_aid', 'researcher', 'admin') NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User profiles with additional information
CREATE TABLE user_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    district VARCHAR(100),
    sub_county VARCHAR(100),
    village VARCHAR(100),
    occupation VARCHAR(100),
    education_level ENUM('none', 'primary', 'secondary', 'tertiary', 'university'),
    profile_image VARCHAR(255),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- User sessions for login tracking
CREATE TABLE user_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- LAND TENURE SYSTEM TABLES
-- =============================================

-- Land tenure types as referenced in the document
CREATE TABLE tenure_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    legal_basis VARCHAR(255),
    historical_origin TEXT,
    vulnerabilities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert the four main tenure types from the document
INSERT INTO tenure_types (name, description, legal_basis, historical_origin, vulnerabilities) VALUES
('Customary', 'Land ownership based on unwritten traditions, norms, and customs of indigenous communities. Covers 75% of Uganda\'s land.', '1995 Constitution, 1998 Land Act', 'Pre-colonial traditions of communities', 'Lack of formal documentation, weakening traditional institutions'),
('Mailo', 'Dual ownership system with registered landlords and tenants by occupancy. Concentrated in central Uganda.', '1995 Constitution, 1998 Land Act', '1900 Buganda Agreement', 'Dual ownership conflict, absentee landlords, fraudulent evictions'),
('Freehold', 'Absolute ownership of registered land in perpetuity. Only available to Ugandan citizens.', '1995 Constitution, 1998 Land Act', '1900 Toro Agreement, 1901 Ankole Agreement', 'High cost of acquisition, bureaucratic registration process'),
('Leasehold', 'Time-limited ownership (49 or 99 years) through contractual arrangement.', '1995 Constitution, 1998 Land Act', 'Contractual grants from landowner', 'Risk of non-renewal, conflicting interests between lessor and lessee');

-- Geographic regions for land distribution
CREATE TABLE regions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO regions (name, description) VALUES
('Northern', 'Northern region of Uganda'),
('Eastern', 'Eastern region of Uganda'),
('Western', 'Western region of Uganda'),
('Central', 'Central region including Buganda Kingdom');

-- Districts table
CREATE TABLE districts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    region_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id)
);

-- Land parcels/properties
CREATE TABLE land_parcels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parcel_id VARCHAR(50) UNIQUE NOT NULL,
    title_number VARCHAR(100),
    tenure_type_id INT NOT NULL,
    district_id INT NOT NULL,
    sub_county VARCHAR(100),
    parish VARCHAR(100),
    village VARCHAR(100),
    size_acres DECIMAL(10,2),
    coordinates_lat DECIMAL(10,8),
    coordinates_lng DECIMAL(11,8),
    land_use ENUM('residential', 'agricultural', 'commercial', 'industrial', 'forest', 'grazing', 'mixed'),
    registration_status ENUM('registered', 'unregistered', 'pending', 'disputed'),
    registration_date DATE,
    description TEXT,
    boundaries_description TEXT,
    is_disputed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenure_type_id) REFERENCES tenure_types(id),
    FOREIGN KEY (district_id) REFERENCES districts(id)
);

-- Land ownership records
CREATE TABLE land_ownership (
    id INT PRIMARY KEY AUTO_INCREMENT,
    land_parcel_id INT NOT NULL,
    owner_id INT NOT NULL,
    ownership_type ENUM('full_owner', 'landlord', 'tenant_by_occupancy', 'lessee', 'family_head', 'clan_representative'),
    ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    acquisition_method ENUM('inheritance', 'purchase', 'allocation', 'grant', 'lease', 'customary_right'),
    supporting_documents TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (land_parcel_id) REFERENCES land_parcels(id),
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

-- Certificate of Customary Ownership (CCO) tracking
CREATE TABLE customary_certificates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    land_parcel_id INT NOT NULL,
    applicant_id INT NOT NULL,
    application_date DATE NOT NULL,
    certificate_number VARCHAR(100),
    status ENUM('applied', 'under_review', 'approved', 'issued', 'rejected', 'expired'),
    issued_date DATE,
    expiry_date DATE,
    issuing_authority VARCHAR(200),
    cost_paid DECIMAL(10,2),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (land_parcel_id) REFERENCES land_parcels(id),
    FOREIGN KEY (applicant_id) REFERENCES users(id)
);

-- =============================================
-- LAND DISPUTES AND GRABBING TRACKING
-- =============================================

-- Land disputes table
CREATE TABLE land_disputes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dispute_number VARCHAR(50) UNIQUE NOT NULL,
    land_parcel_id INT NOT NULL,
    complainant_id INT NOT NULL,
    respondent_id INT NULL,
    dispute_type ENUM('boundary_dispute', 'family_wrangle', 'land_fraud', 'land_grabbing', 'eviction_threat', 'title_dispute', 'inheritance_dispute'),
    status ENUM('reported', 'under_investigation', 'mediation', 'court_case', 'resolved', 'withdrawn'),
    priority ENUM('low', 'medium', 'high', 'critical'),
    description TEXT NOT NULL,
    date_reported DATE NOT NULL,
    date_resolved DATE NULL,
    resolution_method ENUM('traditional_mediation', 'local_council', 'court_ruling', 'police_intervention', 'administrative_decision'),
    resolution_details TEXT,
    evidence_submitted TEXT,
    witnesses TEXT,
    police_case_number VARCHAR(100),
    court_case_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (land_parcel_id) REFERENCES land_parcels(id),
    FOREIGN KEY (complainant_id) REFERENCES users(id),
    FOREIGN KEY (respondent_id) REFERENCES users(id)
);

-- Land grabbing incidents (specific tracking for grabbing cases)
CREATE TABLE land_grabbing_incidents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    incident_number VARCHAR(50) UNIQUE NOT NULL,
    land_parcel_id INT NOT NULL,
    victim_id INT NOT NULL,
    perpetrator_id INT NULL,
    incident_date DATE NOT NULL,
    grabbing_method ENUM('fraud', 'force', 'coercion', 'criminalization_of_victim', 'forged_documents', 'corrupt_officials'),
    violence_involved BOOLEAN DEFAULT FALSE,
    displacement_occurred BOOLEAN DEFAULT FALSE,
    people_affected INT DEFAULT 1,
    property_destroyed TEXT,
    economic_loss_estimate DECIMAL(12,2),
    security_forces_involved BOOLEAN DEFAULT FALSE,
    government_officials_involved BOOLEAN DEFAULT FALSE,
    status ENUM('reported', 'investigating', 'evidence_gathered', 'legal_action', 'resolved', 'ongoing'),
    description TEXT NOT NULL,
    evidence_files TEXT,
    witness_statements TEXT,
    media_coverage TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (land_parcel_id) REFERENCES land_parcels(id),
    FOREIGN KEY (victim_id) REFERENCES users(id),
    FOREIGN KEY (perpetrator_id) REFERENCES users(id)
);

-- Forced evictions tracking
CREATE TABLE forced_evictions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    eviction_number VARCHAR(50) UNIQUE NOT NULL,
    land_parcel_id INT NOT NULL,
    date_of_eviction DATE NOT NULL,
    people_displaced INT NOT NULL,
    households_affected INT NOT NULL,
    evicting_party VARCHAR(255),
    reason_given TEXT,
    legal_notice_given BOOLEAN DEFAULT FALSE,
    notice_period_days INT,
    violence_used BOOLEAN DEFAULT FALSE,
    property_destroyed BOOLEAN DEFAULT FALSE,
    compensation_offered BOOLEAN DEFAULT FALSE,
    compensation_amount DECIMAL(12,2),
    alternative_land_provided BOOLEAN DEFAULT FALSE,
    security_forces_present BOOLEAN DEFAULT FALSE,
    court_order_present BOOLEAN DEFAULT FALSE,
    status ENUM('threatened', 'executed', 'resisted', 'court_challenge', 'resolved'),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (land_parcel_id) REFERENCES land_parcels(id)
);

-- Case studies and notable incidents
CREATE TABLE case_studies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    case_type ENUM('land_grabbing', 'forced_eviction', 'dispute_resolution', 'successful_mediation'),
    location VARCHAR(255),
    date_occurred DATE,
    parties_involved TEXT,
    background TEXT,
    what_happened TEXT,
    outcome TEXT,
    lessons_learned TEXT,
    media_coverage TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- =============================================
-- LEGAL AND INSTITUTIONAL FRAMEWORK
-- =============================================

-- Legal documents and laws
CREATE TABLE legal_documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    document_type ENUM('constitution', 'act', 'regulation', 'policy', 'guideline', 'court_ruling'),
    year_enacted INT,
    description TEXT,
    full_text_url VARCHAR(500),
    relevance_to_land_rights TEXT,
    key_provisions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Government institutions involved in land governance
CREATE TABLE institutions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    institution_type ENUM('ministry', 'commission', 'board', 'court', 'local_council', 'traditional_authority'),
    level ENUM('national', 'regional', 'district', 'sub_county', 'parish', 'village'),
    mandate TEXT,
    contact_information TEXT,
    corruption_reports INT DEFAULT 0,
    effectiveness_rating DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Legal aid providers and services
CREATE TABLE legal_aid_providers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    provider_type ENUM('ngo', 'law_firm', 'government_agency', 'university_clinic', 'individual_lawyer'),
    contact_person VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    services_offered TEXT,
    areas_covered TEXT,
    languages_spoken TEXT,
    cost_structure ENUM('free', 'subsidized', 'commercial'),
    specializations TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- REPORTING AND ANALYTICS TABLES
-- =============================================

-- Statistics tracking for dashboard
CREATE TABLE land_statistics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    statistic_type VARCHAR(100) NOT NULL,
    region_id INT NULL,
    district_id INT NULL,
    value DECIMAL(15,2) NOT NULL,
    percentage DECIMAL(5,2),
    calculation_date DATE NOT NULL,
    data_source VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id),
    FOREIGN KEY (district_id) REFERENCES districts(id)
);

-- Media coverage and news tracking
CREATE TABLE media_coverage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    headline VARCHAR(500) NOT NULL,
    media_outlet VARCHAR(255),
    publication_date DATE,
    article_url VARCHAR(500),
    summary TEXT,
    related_case_id INT NULL,
    related_dispute_id INT NULL,
    tags TEXT,
    sentiment ENUM('positive', 'negative', 'neutral'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (related_case_id) REFERENCES case_studies(id),
    FOREIGN KEY (related_dispute_id) REFERENCES land_disputes(id)
);

-- Educational resources and awareness materials
CREATE TABLE educational_resources (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    resource_type ENUM('article', 'guide', 'video', 'infographic', 'document', 'faq'),
    category ENUM('land_rights', 'dispute_resolution', 'legal_procedures', 'tenure_systems', 'prevention_tips'),
    language ENUM('english', 'luganda', 'runyankole', 'lusoga', 'ateso', 'luo', 'other'),
    content TEXT,
    file_path VARCHAR(500),
    author_id INT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    views_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- =============================================
-- NOTIFICATIONS AND COMMUNICATION
-- =============================================

-- System notifications
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('dispute_update', 'system_alert', 'legal_aid', 'educational', 'warning', 'success'),
    priority ENUM('low', 'medium', 'high', 'urgent'),
    is_read BOOLEAN DEFAULT FALSE,
    related_dispute_id INT NULL,
    related_case_id INT NULL,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (related_dispute_id) REFERENCES land_disputes(id),
    FOREIGN KEY (related_case_id) REFERENCES case_studies(id)
);

-- Contact/support messages
CREATE TABLE support_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    category ENUM('technical_support', 'legal_inquiry', 'report_issue', 'feature_request', 'general'),
    status ENUM('new', 'in_progress', 'resolved', 'closed'),
    priority ENUM('low', 'medium', 'high', 'urgent'),
    assigned_to INT NULL,
    response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);

-- =============================================
-- AUDIT AND SECURITY TABLES
-- =============================================

-- System audit log
CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- File uploads tracking
CREATE TABLE file_uploads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    related_table VARCHAR(50),
    related_id INT,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- User-related indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_national_id ON users(national_id);
CREATE INDEX idx_users_type ON users(user_type);

-- Land-related indexes
CREATE INDEX idx_land_parcels_tenure ON land_parcels(tenure_type_id);
CREATE INDEX idx_land_parcels_district ON land_parcels(district_id);
CREATE INDEX idx_land_parcels_status ON land_parcels(registration_status);
CREATE INDEX idx_land_ownership_parcel ON land_ownership(land_parcel_id);
CREATE INDEX idx_land_ownership_owner ON land_ownership(owner_id);

-- Dispute-related indexes
CREATE INDEX idx_disputes_parcel ON land_disputes(land_parcel_id);
CREATE INDEX idx_disputes_complainant ON land_disputes(complainant_id);
CREATE INDEX idx_disputes_status ON land_disputes(status);
CREATE INDEX idx_disputes_type ON land_disputes(dispute_type);
CREATE INDEX idx_disputes_date ON land_disputes(date_reported);

-- Grabbing incident indexes
CREATE INDEX idx_grabbing_parcel ON land_grabbing_incidents(land_parcel_id);
CREATE INDEX idx_grabbing_victim ON land_grabbing_incidents(victim_id);
CREATE INDEX idx_grabbing_date ON land_grabbing_incidents(incident_date);
CREATE INDEX idx_grabbing_status ON land_grabbing_incidents(status);

-- Notification indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(notification_type);

-- =============================================
-- SAMPLE DATA FOR TESTING
-- =============================================

-- Insert sample districts
INSERT INTO districts (name, region_id) VALUES
('Kampala', 4), ('Wakiso', 4), ('Mukono', 4), -- Central
('Gulu', 1), ('Lira', 1), ('Arua', 1), -- Northern  
('Mbale', 2), ('Soroti', 2), ('Jinja', 2), -- Eastern
('Mbarara', 3), ('Kasese', 3), ('Hoima', 3); -- Western

-- Insert sample admin user
INSERT INTO users (username, email, password_hash, first_name, last_name, user_type, is_verified) VALUES
('admin', 'admin@landmanagement.ug', '$2y$10$example_hash_here', 'System', 'Administrator', 'admin', TRUE);

-- Insert sample legal documents
INSERT INTO legal_documents (title, document_type, year_enacted, description, relevance_to_land_rights) VALUES
('Constitution of Uganda', 'constitution', 1995, 'The supreme law of Uganda', 'Vests land ownership in citizens and recognizes four tenure systems'),
('Land Act', 'act', 1998, 'Comprehensive land law reform', 'Establishes legal framework for land tenure systems and dispute resolution');

-- Insert sample statistics
INSERT INTO land_statistics (statistic_type, value, percentage, calculation_date, data_source) VALUES
('total_land_disputes', 23.0, 23.0, CURDATE(), 'Afrobarometer 2022 Survey'),
('customary_land_coverage', 75.0, 75.0, CURDATE(), 'Research Document'),
('unregistered_land', 70.0, 70.0, CURDATE(), 'Research Document'),
('displaced_persons_2024', 360000, NULL, CURDATE(), 'Witness Radio Report');

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- View for land ownership summary
CREATE VIEW land_ownership_summary AS
SELECT 
    lp.id as parcel_id,
    lp.parcel_id,
    lp.title_number,
    tt.name as tenure_type,
    d.name as district,
    r.name as region,
    lp.size_acres,
    lp.registration_status,
    COUNT(lo.id) as owner_count,
    lp.is_disputed
FROM land_parcels lp
LEFT JOIN tenure_types tt ON lp.tenure_type_id = tt.id
LEFT JOIN districts d ON lp.district_id = d.id
LEFT JOIN regions r ON d.region_id = r.id
LEFT JOIN land_ownership lo ON lp.id = lo.land_parcel_id AND lo.is_active = TRUE
GROUP BY lp.id;

-- View for dispute statistics by region
CREATE VIEW dispute_statistics_by_region AS
SELECT 
    r.name as region,
    COUNT(ld.id) as total_disputes,
    COUNT(CASE WHEN ld.status = 'resolved' THEN 1 END) as resolved_disputes,
    COUNT(CASE WHEN ld.dispute_type = 'land_grabbing' THEN 1 END) as grabbing_cases,
    COUNT(CASE WHEN ld.dispute_type = 'boundary_dispute' THEN 1 END) as boundary_disputes
FROM regions r
LEFT JOIN districts d ON r.id = d.region_id
LEFT JOIN land_parcels lp ON d.id = lp.district_id
LEFT JOIN land_disputes ld ON lp.id = ld.land_parcel_id
GROUP BY r.id, r.name;

-- View for user activity summary
CREATE VIEW user_activity_summary AS
SELECT 
    u.id,
    u.username,
    u.first_name,
    u.last_name,
    u.user_type,
    COUNT(DISTINCT ld.id) as disputes_reported,
    COUNT(DISTINCT lo.id) as lands_owned,
    COUNT(DISTINCT lgi.id) as grabbing_incidents_reported,
    u.created_at as registration_date
FROM users u
LEFT JOIN land_disputes ld ON u.id = ld.complainant_id
LEFT JOIN land_ownership lo ON u.id = lo.owner_id AND lo.is_active = TRUE
LEFT JOIN land_grabbing_incidents lgi ON u.id = lgi.victim_id
GROUP BY u.id;