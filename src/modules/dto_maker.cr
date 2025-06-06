# Module that provides all methods to put data on DTOs.
module App::Modules::DTOMaker
  # Store informations into the DTO for the blog's processing.
  def blog_dto : App::DTO::BlogDTO
    category_id = @form_data.data["category_id"]
    is_published = @form_data.data["is_published"]? == "true"

    blog_dto = App::DTO::BlogDTO.new(
      title: @form_data.data["title"],
      description: @form_data.data["description"],
      content: @form_data.data["content"],
      is_published: is_published,
      category_id: category_id.empty? ? 0i64 : category_id.to_i64
    )

    do_validation(blog_dto)

    blog_dto
  end

  # Store informations into the DTO for the certification's processing.
  def certification_dto : App::DTO::CertificationDTO
    has_certificate = @form_data.data["has_certificate"]? == "true"

    certification_dto = App::DTO::CertificationDTO.new(
      name: @form_data.data["name"],
      has_certificate: has_certificate
    )

    do_validation(certification_dto)

    certification_dto
  end

  # Store informations into the DTO for the project's processing.
  def project_dto : App::DTO::ProjectDTO
    category_id = @form_data.data["category_id"]

    published_at = if !@form_data.data["published_at"].empty?
                     Time.parse_local(@form_data.data["published_at"], "%F")
                   else
                     nil
                   end

    project_dto = App::DTO::ProjectDTO.new(
      title: @form_data.data["title"],
      description: @form_data.data["description"],
      content: @form_data.data["content"],
      category_id: category_id.empty? ? 0i64 : category_id.to_i64,
      realized_at: Time.parse_local(@form_data.data["realized_at"], "%F"),
      published_at: published_at
    )

    do_validation(project_dto)

    project_dto
  end

  # Store all informations into the DTO for the report's processing.
  def report_dto : App::DTO::ReportDTO
    category_id = @form_data.data["category_id"]

    report_dto = App::DTO::ReportDTO.new(
      title: @form_data.data["title"],
      category_id: category_id.empty? ? 0i64 : category_id.to_i64,
      created_at: Time.parse_local(@form_data.data["created_at"], "%F")
    )

    do_validation(report_dto)

    report_dto
  end

  # Store informations into the DTO the skill's processing.
  def skill_dto : App::DTO::SkillDTO
    has_colors = @form_data.data["has_colors"]? == "true"

    skill_dto = App::DTO::SkillDTO.new(
      name: @form_data.data["name"],
      description: @form_data.data["description"],
      has_colors: has_colors
    )

    do_validation(skill_dto)

    skill_dto
  end
end
