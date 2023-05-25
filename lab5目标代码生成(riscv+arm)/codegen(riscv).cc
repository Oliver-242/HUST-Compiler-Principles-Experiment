#include "codegen.h"
#include <memory>
#include <optional>
#include <string>

using namespace llvm;
using namespace llvm::sys;

namespace codegen {
std::string getGenFilename(const std::string &ir_filename,
                           const CodeGenFileType &gen_filetype) {
  if (gen_filetype == CGFT_Null) {
    return nullptr;
  }
  return ir_filename.substr(0, ir_filename.find(".")) +
         (gen_filetype == CGFT_AssemblyFile ? ".s" : ".o");
}

bool codeGenerate(const std::string &ir_filename,
                  const CodeGenFileType &gen_filetype) {
  SMDiagnostic error_smdiagnostic;
  LLVMContext context;
  std::unique_ptr<Module> module =
      parseIRFile(ir_filename, error_smdiagnostic, context);

  if (!module) {
    error_smdiagnostic.print(ir_filename.c_str(), errs());
    return false;
  }

  // Initialize the target registry etc. 
  // *******************************************************************
  // 补充代码1 - 初始化目标
  InitializeAllTargetInfos();
  InitializeAllTargets();
  InitializeAllTargetMCs();
  InitializeAllAsmParsers();
  InitializeAllAsmPrinters();



 
  //auto target_triple = module->getTargetTriple();
  //auto target_triple = getDefaultTargetTriple();
  auto target_triple = "riscv64-unknown-elf";
  //auto target_triple = "armv7-unknown-linux-gnueagihf";
  
  // **********************************************************************
  // 补充代码2 - 指定目标平台


  module->setTargetTriple(target_triple);


  std::string error_string;
  auto target = TargetRegistry::lookupTarget(target_triple, error_string);

  // Print an error and exit if we couldn't find the requested target.
  // This generally occurs if we've forgotten to initialise the
  // TargetRegistry or we have a bogus target triple.
  if (!target) {
    errs() << error_string;
    return 1;
  }

  auto cpu = "generic-rv64";
  // auto cpu = "";
  auto features = "";

  TargetOptions opt;
  auto RM = Optional<Reloc::Model>();
  auto TheTargetMachine =
      target->createTargetMachine(target_triple, cpu, features, opt, RM);

  module->setDataLayout(TheTargetMachine->createDataLayout());

  // *************************************************************************
  // 补充代码3 - 初始化addPassesToEmitFile()的参数，请按以下顺序
  // (1) 调用getGenFilename()函数，获得要写入的目标代码文件名filename
  // (2) 实例化raw_fd_ostream类的对象dest。构造函数： 
  //      raw_fd_ostream(StringRef Filename, std::error_code &EC, sys::fs::OpenFlags Flags);
  //    Flags置sys::fs::OF_None
  //    注意EC是一个std::error_code类型的对象，你需要事先声明EC，
  //    通常还应在调用函数后检查EC，if (EC) 则表明有错误发生(无法创建目标文件)，此时应该输出提示信息后return 1
  // (3) 实例化legacy::PassManager类的对象pass
  // (4) 为file_type赋初值。
  legacy::PassManager pass;
  auto Filename = getGenFilename(ir_filename, gen_filetype);
  std::error_code EC;
  raw_fd_ostream dest(Filename, EC, sys::fs::OF_None);
  if(EC) return 1;
  auto file_type = CGFT_AssemblyFile;

auto filename = getGenFilename(ir_filename, gen_filetype);
std::error_code EC;
raw_fd_ostream dest(filename, EC, sys::fs::OF_None);
if(EC) return 1;
legacy::PassManager pass;
auto file_type = CGFT_AssemblyFile;

  if (TheTargetMachine->addPassesToEmitFile(pass, dest, nullptr, file_type)) {
    errs() << "TheTargetMachine can't emit a file of this type";
    return 1;
  }

  pass.run(*module);
  dest.flush();
  return true;
}


} // namespace codegen