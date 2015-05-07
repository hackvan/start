require 'rails_helper'

RSpec.feature "Resources", type: :feature do

  let!(:user) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:course) { create(:course) }

  context 'when accessed as user' do
    scenario "should redirect to the login when is not logged in" do
      visit new_course_resource_path(course)
      expect(current_path).to eq login_path
    end

    scenario "should not allow access" do
      login(user)
      expect { visit new_course_resource_path(course) }.to raise_error ActionController::RoutingError
    end

    scenario 'display resource when is type markdown Document' do
      resource = create(:resource, type: "markdown", content: Faker::Lorem.paragraph, course: course)
      login(user)

      visit course_path(course)

      click_link "#{resource.title}"

      expect(current_path).to eq course_resource_path(course, resource)
    end
  end

  context 'when accessed as admin' do
    scenario "show form new resource" do
      login(admin)

      visit course_path(course)
      expect(page).to have_content "Nuevo Recurso"

      click_link "Nuevo Recurso"

      expect(page.current_path).to eq new_course_resource_path(course)
    end

    scenario "create resource with valid input when is url type" do
      login(admin)

      visit course_path(course)
      click_link "Nuevo Recurso"

      expect{
        fill_in 'resource_title', with: Faker::Name.title
        fill_in 'resource_description', with: Faker::Lorem.paragraph
        select "External URL", from: 'resource_type'
        fill_in 'resource_url', with: Faker::Internet.url
        fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
        click_button  'Crear Resource'
      }.to change(Resource, :count).by 1

      expect(Resource.last).not_to be_nil
      expect(current_path).to eq course_path(course)
    end

    scenario "create resource with valid input when is markdown document type", js: true do
      login(admin)

      visit course_path(course)
      click_link "Nuevo Recurso"

      expect{
        fill_in 'resource_title', with: Faker::Name.title
        fill_in 'resource_description', with: Faker::Lorem.paragraph
        select "Markdown Document", from: 'resource_type'
        fill_in 'resource_content', with: Faker::Lorem.paragraph
        fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
        click_button  'Crear Resource'
      }.to change(Resource, :count).by 1

      expect(Resource.last).not_to be_nil
      expect(current_path).to eq course_path(course)
    end

    scenario "create resource without valid input when is url" do
      login(admin)

      visit course_path(course)
      click_link "Nuevo Recurso"

      expect{
        fill_in 'resource_title', with: Faker::Name.title
        fill_in 'resource_url', with: Faker::Internet.url
        fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
        click_button  'Crear Resource'
      }.not_to change(Resource, :count)

      expect(page).to have_selector ".panel-danger"
      expect(current_path).to eq course_resources_path(course)
    end

    scenario "create resource without valid input when is content", js: true do
      login(admin)

      visit new_course_resource_path(course_id: course.id)

      expect{
        fill_in 'resource_title', with: Faker::Name.title
        select "Markdown Document", from: 'resource_type'
        fill_in 'resource_content', with: Faker::Lorem.paragraph
        fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
        click_button  'Crear Resource'
      }.not_to change(Resource, :count)

      expect(page).to have_selector ".panel-danger"
      expect(current_path).to eq course_resources_path(course)
    end

    scenario "show form edit resource", js: true do
      resource = create(:resource, course: course)
      create(:resource, course: course)

      login(admin)

      visit course_path(course)
      all('.resources span.action-edit', count: 2).first.click

      expect(page).to have_content "Editar Recurso"
      expect(current_path).to eq edit_course_resource_path(course, resource)
    end

    scenario "edit resource with valid input", js: true do
      resource = create(:resource, course: course)
      create(:resource, course: course)

      login(admin)

      visit edit_course_resource_path(course, resource)

      title = Faker::Name.title
      description =  Faker::Lorem.paragraph
      url = Faker::Internet.url

      fill_in 'resource_title', with: title
      fill_in 'resource_description', with: description
      select "External URL", from: 'resource_type'
      fill_in 'resource_url', with: url
      fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
      click_button  'Actualizar Resource'

      resource = Resource.find(resource.id)
      expect(resource.title).to eq title
      expect(resource.description).to eq description
      expect(resource.url).to eq url
      expect(resource.type).to eq Resource.types.keys.first

      wait_for_ajax
      expect(current_path).to eq course_path(course)
    end

    scenario "edit resource without invalid input", js: true do
      resource = create(:resource, course: course)
      create(:resource, course: course)

      login(admin)

      visit edit_course_resource_path(course, resource)

      title = Faker::Name.title
      description =  Faker::Lorem.paragraph
      url = Faker::Internet.url

      fill_in 'resource_title', with: title
      fill_in 'resource_description', with: nil
      select "External URL", from: 'resource_type'
      fill_in 'resource_url', with: url
      fill_in 'resource_time_estimate', with: "#{Faker::Number.digit} days"
      click_button  'Actualizar Resource'

      wait_for_ajax
      expect(page).to have_selector ".panel-danger"
      expect(current_path).to eq course_resource_path( course, resource)
    end

    scenario "Delete resource", js: true do
      resource = create(:resource, course: course)
      create(:resource, course: course)

      login(admin)

      all('a', text: 'Entrar').first.click
      all('.resources span.action-remove', count: 2).first.click
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax

      expect(course.resources.count).to eq 1
      expect(page).to have_selector('.resources tr', count: 1)
    end
  end
end
