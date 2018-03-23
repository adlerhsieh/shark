RSpec.describe AuditLog, type: :model do

  describe "#write" do
    let!(:log) { create(:audit_log) }
    
    subject { log.write("foo") }

    it "writes to the log" do
      expect { subject }.to change { log.reload.content }.to("foo\n")
    end
  end

  describe "#error" do
    let!(:log) { create(:audit_log) }

    subject do 
      ex = StandardError.new("bar")
      ex.set_backtrace("x")

      log.error(ex)
    end
    
    it "writes to the log" do
      subject

      expect(log.content).to include("bar")
    end
  end

end
