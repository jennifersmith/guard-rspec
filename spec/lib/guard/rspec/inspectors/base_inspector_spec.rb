RSpec.describe Guard::RSpec::Inspectors::BaseInspector do
  let(:options) { { custom: "value", spec_paths: %w(myspec) } }
  let(:inspector) { Guard::RSpec::Inspectors::BaseInspector.new(options) }
  let(:paths) { %w(spec/foo_spec.rb spec/bar_spec.rb) }
  let(:abstract_error) { "Must be implemented in subclass" }

  describe ".initialize" do
    it "sets options and spec_paths" do
      expect(inspector.options).to include(:custom, :spec_paths)
      expect(inspector.options[:custom]).to eq("value")
      expect(inspector.spec_paths).to eq(%w(myspec))
    end
  end

  describe "#paths" do
    it "should not be implemented here" do
      expect { inspector.paths(paths) }.to raise_error(abstract_error)
    end

    context "specific inspector" do
      class FooInspector < Guard::RSpec::Inspectors::BaseInspector
        def paths(paths)
          _clean(paths)
        end
      end

      let(:options) do
        {
          chdir: chdir,
          spec_paths: ["spec"]
        }
      end
      let(:chdir) { nil }
      let(:inspector) { FooInspector.new(options) }

      subject { inspector.paths(paths) }

      context "_select_only_spec_dirs" do
        let(:paths) { ["spec"] }

        it "returns matching paths" do
          allow(File).to receive(:directory?).
            with("spec").and_return(false)

          expect(subject).to eq(paths)
        end

        context "chdir option present" do
          let(:chdir) { "moduleA" }
          let(:paths) { ["#{chdir}/spec"] }

          it "returns matching paths" do
            allow(File).to receive(:directory?).
              with("moduleA/spec").and_return(false)

            expect(subject).to eq(paths)
          end
        end
      end

      context "_select_only_spec_files" do
        let(:paths) do
          ["app/models/a_foo.rb", "spec/models/a_foo_spec.rb"]
        end
        let(:spec_files) do
          [["spec/models/a_foo_spec.rb",
            "spec/models/b_foo_spec.rb"]]
        end

        before do
          allow(Dir).to receive(:[]).and_return(spec_files)
        end

        it "returns matching paths" do
          expect(subject).to eq(["spec/models/a_foo_spec.rb"])
        end

        context "chdir option present" do
          let(:chdir) { "moduleA" }
          let(:paths) do
            ["moduleA/models/a_foo.rb", "spec/models/a_foo_spec.rb"]
          end
          let(:spec_files) do
            [["moduleA/spec/models/a_foo_spec.rb",
              "moduleA/spec/models/b_foo_spec.rb"]]
          end

          it "returns matching paths" do
            expect(subject).to eq(["spec/models/a_foo_spec.rb"])
          end
        end
      end
    end
  end

  describe "#failed" do
    it "should not be implemented here" do
      expect { inspector.failed(paths) }.to raise_error(abstract_error)
    end
  end

  describe "#reload" do
    it "should not be implemented here" do
      expect { inspector.reload }.to raise_error(abstract_error)
    end
  end
end
