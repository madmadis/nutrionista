package ee.nutrionista.persistence.faq;

import ee.nutrionista.controller.faq.dto.FaqItemDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface FaqItemMapper {
    FaqItemDto toDto(FaqItem faqItem);
}
