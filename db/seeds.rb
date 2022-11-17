roles = %w[admin doctor patient]
roles.each { |role| Role.create!(name: role) }

departments = %w[Pediatrics Psychiatry Orthodontics]
departments.each { |department| Department.create!(name: department) }

admin =
  User.create!(
    role_id: Role.find_by(name: 'admin').id,
    first_name: 'Jivemed Admin',
    last_name: 'Jivemed Admin',
    email: 'jivemed.admin@email.com',
    password: Rails.application.credentials.users.admin_password
  )
admin.update!(email_verified: true)

doctor =
  User.create!(
    role_id: Role.find_by(name: 'doctor').id,
    first_name: 'Maria',
    last_name: 'Dela Cruz',
    email: 'mdc.doctor@email.com',
    password: Rails.application.credentials.users.doctor_password
  )
doctor.update!(email_verified: true)
doctor.departments << Department.find_by(name: 'Pediatrics')
doctor.create_doctor_fee!(amount: 1000)

patient =
  User.create!(
    role_id: Role.find_by(name: 'patient').id,
    first_name: 'Juan',
    last_name: 'Dela Cruz',
    email: 'jdc@email.com',
    password: Rails.application.credentials.users.patient_password
  )
patient.update!(email_verified: true)

schedule = Schedule.create!(user_id: doctor.id, date: Date.parse('2022-01-31')) # YYYY-MM-DD

# user_transaction =
#   UserTransaction.create!(
#     user_id: patient.id,
#     email: patient.email,
#     stripe_id: 'test_stripe_id_123456',
#     amount: 1_333_425.to_f / 100 # 1333425 = 13334.25
#   )

# appointment =
#   Appointment.create!(
#     user_id: patient.id,
#     schedule_id: schedule.id,
#     user_transaction_id: user_transaction.id
#   )
# update_schedule = Schedule.find(appointment.schedule_id)
# update_schedule.update(available: update_schedule.available - 1)
