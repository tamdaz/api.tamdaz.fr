require "colorize"
require "json"
require "db"
require "mysql"
require "athena-mime"

@[ADI::Register]
@[ACONA::AsCommand(
  "tz:data-import",
  description: "Start importing data into the new database version"
)]
class App::Commands::DataImportCommand < ACON::Command
  DELAY_ITERATION = 20.milliseconds

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : Status
    style = ACON::Style::Athena.new input, output

    process_categories(output)
    process_blogs(output)
    process_certifications(output)
    process_projects(output)
    process_reports(output)
    process_skills(output)
    process_timelines(output)
    process_tws(output)
    process_files(output)

    style.success "Data migration has been successfully executed."

    Status::SUCCESS
  end

  private def progress_bar(output : ACON::Output::Interface) : ACON::Helper::ProgressBar
    progress = ACON::Helper::ProgressBar.new output
    progress.bar_width = 50
    progress.format = "[%bar%] %current%/%max% -- %message%\n"
    progress.empty_bar_character = "\u00B7".colorize(:dark_gray).to_s
    progress.progress_character = ">".colorize(:yellow).to_s
    progress.bar_character = "\u2015".colorize(:green).to_s

    progress
  end

  private def process_blogs(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/blogs.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |blog|
      progress.set_message "Importing the blog..."

      App::Models::Blog.create!(
        id: blog["id"].as_s.to_i64,
        title: blog["title"].as_s,
        description: blog["description"].as_s,
        content: blog["content"].as_s,
        is_published: blog["is_published"].as_s,
        category_id: App::Models::Category.find_by!(name: blog["category"].as_s).id
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Blogs imported successfully!"
    progress.finish
  end

  private def process_categories(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/categories.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |category|
      progress.set_message "Importing the category: #{category["name"]}"
      App::Models::Category.create!(
        name: category["name"].as_s,
        usage: select_usage!(category["used_for"].as_s)
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Categories imported successfully!"
    progress.finish
  end

  private def process_certifications(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/certifications.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |certification|
      progress.set_message "Importing the certification..."

      App::Models::Certification.create!(
        id: certification["id"].as_s.to_i64,
        name: certification["primary"].as_s,
        has_certificate: certification["has_certificate"].as_s
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Certifications imported successfully!"
    progress.finish
  end

  private def process_projects(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/projects.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |project|
      progress.set_message "Importing the project..."

      published_at = if project["published_at"].as_s?
                       Time.parse_utc(project["published_at"].as_s, "%F")
                     end

      App::Models::Project.create!(
        title: project["title"].as_s,
        description: project["description"].as_s,
        content: project["content"].as_s,
        category_id: App::Models::Category.find_by!(name: project["category"].as_s).id,
        realized_at: Time.parse_utc(project["realized_at"].as_s, "%F"),
        published_at: published_at
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Projects imported successfully!"
    progress.finish
  end

  private def process_reports(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/reports.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |report|
      progress.set_message "Importing the report..."

      App::Models::Report.create!(
        title: report["title"].as_s,
        category_id: App::Models::Category.find_by!(name: report["category"].as_s).id,
        created_at: Time.parse_utc(report["file_created_at"].as_s, "%F")
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Reports imported successfully!"
    progress.finish
  end

  private def process_skills(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/skills.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.iterate(json.as_a) do |skill|
      progress.set_message "Importing the skill..."

      App::Models::Skill.create!(
        name: skill["name"].as_s,
        description: skill["description"].as_s,
        has_colors: skill["has_no_colors"].as_s != "0"
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Skills imported successfully!"
    progress.finish
  end

  private def process_timelines(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/timelines.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.set_message "Importing the timeline..."

    progress.iterate(json.as_a) do |timeline|
      App::Models::Timeline.create!(
        date_start: Time.parse_utc(timeline["date_start"].as_s, "%F"),
        date_end: Time.parse_utc(timeline["date_end"].as_s, "%F"),
        description: timeline["description"].as_s,
        type: timeline["type"].as_s
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "Timelines imported successfully!"
    progress.finish
  end

  private def process_tws(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/tw.json") do |file|
      JSON.parse(file)[-1]["data"]
    end

    progress.set_message "Importing the TW..."

    progress.iterate(json.as_a) do |tw|
      App::Models::TW.create!(
        title: tw["title"].as_s,
        description: tw["description"].as_s,
        image_url: tw["image_url"].as_s,
        source_url: tw["source_url"].as_s,
        published_at: Time.parse_utc(tw["published_at"].as_s, "%F"),
        source: tw["source"].as_s,
      )

      sleep DELAY_ITERATION
    end

    progress.set_message "TWs imported successfully!"
    progress.finish
  end

  private def process_files(output : ACON::Output::Interface) : Void
    progress = progress_bar(output)

    json = File.open("./dev/json/media.json") do |file|
      JSON.parse(file)[-1]["data"]
    end


    progress.iterate(json.as_a) do |media|
      progress.set_message "Importing the file... #{media["file_name"]}"

      mime_types = AMIME::Types.new
      extension = mime_types.extensions(media["mime_type"].as_s)[0]

      file_name = media["uuid"].to_s + '.' + extension

      file_source = "./dev/data/#{media["id"]}/#{media["file_name"]}"
      file_destination = "./uploads/#{file_name}"

      App::Models::File.create!(
        model_id: media["model_id"].as_s,
        model_type: media["model_type"].as_s.gsub("App\\Infrastructure\\Models\\", "App::Models::"),
        path: file_name
      )

      # Copy the file into the `uploads/` directory.
      File.copy(file_source, file_destination)

      sleep DELAY_ITERATION
    end

    progress.set_message "Files imported successfully!"
    progress.finish
  end

  # Select an usage for an created or updated category.
  private def select_usage!(usage : String) : App::Enums::Categories::Usage
    case usage
    when "blogs"    then App::Enums::Categories::Usage::Blogs
    when "reports"  then App::Enums::Categories::Usage::Reports
    when "projects" then App::Enums::Categories::Usage::Projects
    else
      raise "Category usage is unknown."
    end
  end
end
