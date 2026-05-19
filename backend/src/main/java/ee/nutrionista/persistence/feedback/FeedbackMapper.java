package ee.nutrionista.persistence.feedback;

import ee.nutrionista.controller.feedback.dto.FeedbackDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {
    Feedback toEntity(FeedbackDto dto);
}
