package ee.nutrionista.persistence.faq;

import ee.nutrionista.controller.faq.dto.FaqItemDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface FaqItemMapper {

    @Mapping(source = "id", target = "faqItemId")
    @Mapping(source = "section", target = "section")
    @Mapping(source = "question", target = "question")
    @Mapping(source = "answer", target = "answer")
    FaqItemDto toFaqItemDto(FaqItem faqItem);

    List<FaqItemDto> toFaqItemDtos(List<FaqItem> faqItems);
}