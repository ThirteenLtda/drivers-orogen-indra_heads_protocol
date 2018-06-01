/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include <iodrivers_base/ConfigureGuard.hpp>
#include <indra_heads_protocol/Driver.hpp>
#include <iostream>

using namespace indra_heads_protocol;

Task::Task(std::string const& name)
    : TaskBase(name)
{
}

Task::Task(std::string const& name, RTT::ExecutionEngine* engine)
    : TaskBase(name, engine)
{
}

Task::~Task()
{
}



/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    iodrivers_base::ConfigureGuard guard(this);
    Driver* driver = new Driver();
    if (!_io_port.get().empty())
        driver->openURI(_io_port.get());
    setDriver(driver);

    if (! TaskBase::configureHook())
        return false;

    mDriver = driver;
    guard.commit();
    return true;
}
bool Task::startHook()
{
    if (! TaskBase::startHook())
        return false;
    return true;
}
void Task::updateHook()
{
    Response response;
    while (_response.read(response) == RTT::NewData)
    {
        mDriver->writeResponse(response);
    }

    TaskBase::updateHook();
}
void Task::processIO()
{
    try {
        auto msg_id = mDriver->readRequest();
        if (msg_id == ID_ENABLE_STABILIZATION)
        {
            mDriver->writeResponse(
                Response{ ID_ENABLE_STABILIZATION, STATUS_OK });
            return;
        }
        auto conf = mDriver->getRequestedConfiguration();
        _requested_configuration.write(conf);
    }
    catch(iodrivers_base::TimeoutError) {
        std::cerr << "Timed out while trying to decode a request" << std::endl;
    }
}
void Task::errorHook()
{
    TaskBase::errorHook();
}
void Task::stopHook()
{
    TaskBase::stopHook();
}
void Task::cleanupHook()
{
    TaskBase::cleanupHook();
}
