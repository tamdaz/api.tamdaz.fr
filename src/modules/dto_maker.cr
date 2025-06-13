# Module that provides all methods to put data on DTOs.
module App::Modules::DTOMaker
  # Store informations into the DTO for the blog's processing.
  def blog_dto : App::DTO::BlogDTO
    blog_dto = App::DTO::BlogDTO.new(@form_data)
    do_validation(blog_dto)
    blog_dto
  end

  # Store informations into the DTO for the certification's processing.
  def certification_dto : App::DTO::CertificationDTO
    certification_dto = App::DTO::CertificationDTO.new(@form_data)
    do_validation(certification_dto)
    certification_dto
  end

  # Store informations into the DTO for the project's processing.
  def project_dto : App::DTO::ProjectDTO
    project_dto = App::DTO::ProjectDTO.new(@form_data)
    do_validation(project_dto)
    project_dto
  end

  # Store all informations into the DTO for the report's processing.
  def report_dto : App::DTO::ReportDTO
    report_dto = App::DTO::ReportDTO.new(@form_data)
    do_validation(report_dto)
    report_dto
  end

  # Store informations into the DTO the skill's processing.
  def skill_dto : App::DTO::SkillDTO
    skill_dto = App::DTO::SkillDTO.new(@form_data)
    do_validation(skill_dto)
    skill_dto
  end
end
