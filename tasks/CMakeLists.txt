# Generated from orogen/lib/orogen/templates/tasks/CMakeLists.txt

include(indra_heads_protocolTaskLib)
ADD_LIBRARY(${INDRA_HEADS_PROTOCOL_TASKLIB_NAME} SHARED 
    ${INDRA_HEADS_PROTOCOL_TASKLIB_SOURCES})
add_dependencies(${INDRA_HEADS_PROTOCOL_TASKLIB_NAME}
    regen-typekit)



TARGET_LINK_LIBRARIES(${INDRA_HEADS_PROTOCOL_TASKLIB_NAME}
    ${OrocosRTT_LIBRARIES}
    ${QT_LIBRARIES}
    ${INDRA_HEADS_PROTOCOL_TASKLIB_DEPENDENT_LIBRARIES})
SET_TARGET_PROPERTIES(${INDRA_HEADS_PROTOCOL_TASKLIB_NAME}
    PROPERTIES LINK_INTERFACE_LIBRARIES "${INDRA_HEADS_PROTOCOL_TASKLIB_INTERFACE_LIBRARIES}")
SET_TARGET_PROPERTIES(${INDRA_HEADS_PROTOCOL_TASKLIB_NAME}
    PROPERTIES INTERFACE_LINK_LIBRARIES "${INDRA_HEADS_PROTOCOL_TASKLIB_INTERFACE_LIBRARIES}")

INSTALL(TARGETS ${INDRA_HEADS_PROTOCOL_TASKLIB_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib/orocos)

INSTALL(FILES ${INDRA_HEADS_PROTOCOL_TASKLIB_HEADERS}
    DESTINATION include/orocos/indra_heads_protocol)

