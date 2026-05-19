package ee.nutrionista.persistence.feedback;

import ee.nutrionista.controller.feedback.dto.FeedbackDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {

    @Mapping(source = "name", target = "name")
    @Mapping(source = "email", target = "email")
    @Mapping(source = "message", target = "message")
    Feedback toEntity(FeedbackDto dto);
}