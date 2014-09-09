# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140812085256) do

  create_table "question_options", force: true do |t|
    t.integer  "question_id"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: true do |t|
    t.string   "ques"
    t.string   "quetype"
    t.string   "multichoice"
    t.string   "isactive"
    t.string   "answers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", force: true do |t|
    t.integer  "test_id"
    t.integer  "user_id"
    t.integer  "correct"
    t.integer  "incorrect"
    t.string   "test_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", force: true do |t|
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", force: true do |t|
    t.string   "subject"
    t.string   "createdby"
    t.integer  "duration"
    t.integer  "quescount"
    t.string   "isactive"
    t.string   "testname"
    t.string   "testlogin"
    t.string   "testpass"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "activity",           limit: 10
    t.string   "usertype",           limit: 20
    t.string   "name",               limit: 50
    t.string   "email",              limit: 60
    t.integer  "experience"
    t.string   "phone",              limit: 11
    t.string   "encrypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
