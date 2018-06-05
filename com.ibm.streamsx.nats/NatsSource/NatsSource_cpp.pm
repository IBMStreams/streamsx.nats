
package NatsSource_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '/* Additional includes go here */', "\n";
   print "\n";
   print '#include <stdio.h>', "\n";
   print '#include <stdlib.h>', "\n";
   print "\n";
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   print '// Constructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR()', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   print '// Destructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR()', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   print '// Notify port readiness', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady()', "\n";
   print '{', "\n";
   print '    createThreads(1);', "\n";
   print '}', "\n";
   print "\n";
   print '// Notify pending shutdown', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown()', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   
   my $outputAttribute = "";
   if (defined $model->getOutputPortAt(0)) {
       sub getOutputAttribute {
           my $outputPort = $model->getOutputPortAt(0);
   
           for my $attribute (@{$outputPort->getAttributes()}) {
               if (SPL::CodeGen::Type::isBlob($attribute->getSPLType())) {
                   return $attribute->getName();
               }
           }
   
           die("No blob attribute on output port");
       }
   
       $outputAttribute = getOutputAttribute();
   } else {
       die("Need to have an output port attached");
   }
   
   print "\n";
   print "\n";
   print '// Processing for source and threaded operators', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(uint32_t idx)', "\n";
   print '{', "\n";
   print '  // set up the initial connection', "\n";
   print '  std::string hostname = ';
   print $model->getParameterByName("hostname")->getValueAt(0)->getCppExpression();
   print ';', "\n";
   print '  int port = ';
   print $model->getParameterByName("port")->getValueAt(0)->getCppExpression();
   print ';', "\n";
   print '  // TODO fail if port is out of bounds', "\n";
   print "\n";
   print '  char * portString = new char[6];', "\n";
   print '  memset(portString, 0, 6);', "\n";
   print '  snprintf(portString, 6, "%d", port);', "\n";
   print "\n";
   print '  ';
    if (defined $model->getParameterByName("token")) { 
   print "\n";
   print "\n";
   print '  std::string token = ';
   print $model->getParameterByName("token")->getValueAt(0)->getCppExpression();
   print ';', "\n";
   print '  std::string url = "nats://" + token + "@" + hostname + ":" + std::string(portString);', "\n";
   print "\n";
   print '  ';
    } else { 
   print "\n";
   print "\n";
   print '  std::string url = "nats://" + hostname + ":" + std::string(portString);', "\n";
   print "\n";
   print '  ';
    } 
   print "\n";
   print "\n";
   print '  natsConnection_ConnectTo(&(this->nc), url.c_str());', "\n";
   print "\n";
   print '  ';
    my $subject = $model->getParameterByName("subject")->getValueAt(0)->getCppExpression(); 
   print "\n";
   print '  ';
    if (defined $model->getParameterByName("queueGroup")) { 
   print "\n";
   print "\n";
   print '  std::string queueGroup = ';
   print $model->getParameterByName("queueGroup")->getValueAt(0)->getCppExpression();
   print ';', "\n";
   print '  natsConnection_QueueSubscribeSync(&(this->sub), this->nc, ';
   print $subject;
   print '.c_str(), queueGroup.c_str());', "\n";
   print "\n";
   print '  ';
    } else { 
   print "\n";
   print "\n";
   print '  natsConnection_SubscribeSync(&(this->sub), this->nc, ';
   print $subject;
   print '.c_str());', "\n";
   print "\n";
   print '  ';
    } 
   print "\n";
   print "\n";
   print '  natsStatus status;', "\n";
   print '  OPort0Type outTuple;', "\n";
   print '  while(!getPE().getShutdownRequested()) {', "\n";
   print '      status = natsSubscription_NextMsg(&(this->msg), this->sub, 1000);', "\n";
   print "\n";
   print '      if (status == NATS_OK && this->msg != NULL) {', "\n";
   print '          const char * data = natsMsg_GetData(this->msg);', "\n";
   print '          int dataLength = natsMsg_GetDataLength(this->msg);', "\n";
   print '          outTuple.set_';
   print $outputAttribute;
   print '(SPL::blob((unsigned char *) data, dataLength));', "\n";
   print '          submit(outTuple, 0);', "\n";
   print '      }', "\n";
   print "\n";
   print '      natsMsg_Destroy(this->msg);', "\n";
   print '      this->msg = NULL;', "\n";
   print '  }', "\n";
   print "\n";
   print '  natsSubscription_Unsubscribe(this->sub);', "\n";
   print '  natsSubscription_Destroy(this->sub);', "\n";
   print "\n";
   print '  natsConnection_Destroy(this->nc);', "\n";
   print '}', "\n";
   print "\n";
   print '// Tuple processing for mutating ports', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple & tuple, uint32_t port)', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   print '// Tuple processing for non-mutating ports', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port)', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   print '// Punctuation processing', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Punctuation const & punct, uint32_t port)', "\n";
   print '{', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
