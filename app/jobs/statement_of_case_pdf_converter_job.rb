require 'libreconv'
class StatementOfCasePdfConverterJob < ApplicationJob
  queue_as :default


  def perform(statement_of_case_id)
    statement_of_case = StatementOfCase.find statement_of_case_id
    original_file = statement_of_case.original_file
    original_filename = original_file.filename.to_s
    original_filename_base_part = File.basename(original_filename, File.extname(original_filename))

    temp_downloaded_original_file_path = download(original_file)
    temp_pdf_file_path = convert(temp_downloaded_original_file_path)
    attach_pdf(statement_of_case, temp_pdf_file_path, original_filename_base_part)
    File.unlink(temp_downloaded_original_file_path)
    File.unlink(temp_pdf_file_path)
  end

  private

  def download(original_file)
    fp = Tempfile.new('original_statement_of_case')
    fp.binmode
    binary = original_file.download
    fp.write(binary)
    fp.close
    fp.path
  end

  def convert(download_original_file_path)
    fp = Tempfile.new(['pdf_statement_of_case', '.pdf'])
    Libreconv.convert(download_original_file_path, fp.path)
    fp.path
  end

  def attach_pdf(statement_of_case, temp_filename, final_root_name)
    final_name = final_root_name + '.pdf'
    puts "Attaching #{temp_filename} to SOC #{statement_of_case.id} as #{final_name}"

    statement_of_case.pdf_file.attach(
      io: File.open('/path/to/file'),
      filename: 'file.pdf',
      content_type: 'application/pdf',
      identify: false
    )


  end
end
