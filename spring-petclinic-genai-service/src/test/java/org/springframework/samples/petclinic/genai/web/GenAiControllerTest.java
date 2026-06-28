package org.springframework.samples.petclinic.genai.web;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(GenAiController.class)
@ActiveProfiles("test")
class GenAiControllerTest {

	@Autowired
	private MockMvc mvc;

	@Test
	void shouldReturnGenAiServiceStatus() throws Exception {
		mvc.perform(get("/genai/status").accept(MediaType.APPLICATION_JSON))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.service").value("genai-service"))
			.andExpect(jsonPath("$.status").value("UP"))
			.andExpect(jsonPath("$.description").value("Spring PetClinic Generative AI microservice"));
	}

}
